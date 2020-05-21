#!/bin/bash

# Cut videos using ffmpeg
# Usage: autocut filename timestamp1 timestamp2 timestamp 3 ...  (timestamp : hh:mm)

echo "$# parameters found"

IN=$1
START="00:00"
#Getting end of video by it's duration
END=$(ffmpeg -i $IN 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,//)
count=0

#To get: filename without extenstion
base=$(echo $IN | sed 's/\.[^.]*$//')
#To get: file extension
ext=$(echo $IN | sed 's@.*\.@@')

echo "base: $base ; ext: $ext"


if [ $# -gt 1 ]; then
	echo "Going to make some good cuts. Hang on..."
else
	echo "Enter in this format : autocut filename hh:mm hh:mm ..."
	exit 1
fi

makeTheCut(){
newfilename=$(echo "cut_${count}_${base}__${1}_${2}.${ext}")
echo "Making #$count cut :  $1-$2"
echo "Creating new file : $newfilename"
ffmpeg -i $IN -ss $1 -to $2 -c copy $newfilename
}

echo "Going to make some cuts in this $END long video"

count=2
lastcut=$START
while [ $count -le $# ]; do
makeTheCut $lastcut ${!count}
lastcut=${!count}
count=$[$count+1]
done

#one more cut for last clip till the end
makeTheCut $lastcut $END
