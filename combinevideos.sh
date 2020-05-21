#!/bin/bash

# Purpose of this code: Combine multiple videos to create one single video
# Input : combinevideos file_containing_list_of_files.txt
# Structure of file_containing_list_of_files.txt is as follows \/
# file myfile1.mp4
# file myfile2.mp4 ...

# Output: New file will be created with the name combined2files_myfile1_myfile2.mp4

FILE_LIST=$1

filescount=$(wc -l $FILE_LIST | awk '{ print $1 }')
finalfilepath="combined${filescount}files"

echo "Going to combine following videos as mentioned in ${FILE_LIST}..."

function float_gt() {
    perl -e "{if($1>$2){print 1} else {print 0}}"
}


count=1
largest_duration=0;
longest_video="";
timebase_of_largest_video=0;
filearray=()
while IFS= read -r line
do 
  #process only lines which start with keyword 'file'
  keyword=$(echo $line | awk -F'[ ]' '{ print $1 }')
  if [ "$keyword" != "file" ]
  then
	#the line doesn't start with keyord file, ignore
	continue
  fi
  filepath=$(echo $line | awk -F'[ ]' '{ print $2 }')
  filearray+=("$filepath")
  base=$(echo $filepath | sed 's/\.[^.]*$//')
  timebase=$(ffprobe -loglevel warning -show_streams $filepath | awk '/^time_base/' | awk -F\= '{ "basename "$1"" |& getline $1; print $2;exit}'|awk -F\/ '{print $2}')
  duration=$(ffprobe -loglevel warning -v error -show_entries format=duration  -of default=noprint_wrappers=1:nokey=1 $filepath)
  echo "${count}: $filepath ; duration: $duration s; time_base: $timebase"
  count=$[$count+1]
  #Find the longest video and remeber it's timebase
  if [ $(float_gt $duration $largest_duration) == 1 ]
  then
  	largest_duration=$duration
        timebase_of_largest_video=$timebase
        longest_video="$filepath"
  fi
  #finalfilepath generation: apending all file names except when filename exceeds 30 characters
  if [ ${#finalfilepath} -lt 30 ]
  then
	finalfilepath="${finalfilepath}_$base"
  fi
done < "$FILE_LIST"

finalfilepath="${finalfilepath}.mp4"

echo ""
echo -e "\e[1mLongest video is $longest_video\e[0m with duration: $largest_duration and \e[1mtimebase: $timebase_of_largest_video\e[0m"
echo ""

#Step 1 : Fix the time_base of all videos(why? detail in the references section of this script)
newfilearray=()
setTimeBase(){	
  timebase=$(ffprobe -loglevel warning -show_streams $1 | awk '/^time_base/' | awk -F\= '{ "basename "$1"" |& getline $1; print $2;exit}'|awk -F\/ '{print $2}')
  #if timebase is different than what we want to fix, create a temporary video with new timebase
  if [ $timebase -ne $2 ]
  then
	  tmp_filename="tmp_${2}_$1"
	  echo -e "\e[7mChanging timebase for file: $1 from $timebase to $2 tbn and saving new file at $tmp_filename\e[0m"
	  ffmpeg -loglevel warning -i $1 -video_track_timescale $2 $tmp_filename
          newfilearray+=("$tmp_filename")
  else
	newfilearray+=("$1")
  fi
}

for i in ${!filearray[@]}; do
  setTimeBase ${filearray[$i]} $timebase_of_largest_video
done

#create a new text file to store all file names that we want to concat
newfilelistwithsyncdtimebase="tmp_combine_file_list"

for i in ${!newfilearray[@]}; do
  filepath="${newfilearray[$i]}"
  base=$(echo $filepath | sed 's/\.[^.]*$//')
  newfilelistwithsyncdtimebase="${newfilelistwithsyncdtimebase}_$base" 
done

newfilelistwithsyncdtimebase="${newfilelistwithsyncdtimebase}.txt" 

if [ ! -f "$newfilelistwithsyncdtimebase" ]
then
	echo "Creating file ${newfilelistwithsyncdtimebase}"
	touch $newfilelistwithsyncdtimebase
else
	echo "File '${newfilelistwithsyncdtimebase}' already exists. Remove it and run this again to create a new combined video."
	exit
fi

for i in ${!newfilearray[@]}; do
  echo "file ${newfilearray[$i]}" >> $newfilelistwithsyncdtimebase
done


echo ""
echo "Preparing output $finalfilepath"
echo ""

#Step 2: concatenate the files using the updated list of files
ffmpeg -f concat -safe 0 -i $newfilelistwithsyncdtimebase -copytb 0 -c copy -loglevel warning $finalfilepath 


# References
# -loglevel warning for less verbose command print
# -c copy to skip encoding the videos again

# ISSUE: DTS out of order https://stackoverflow.com/a/56002050/7360184 (unexpected output when encoding does not match)
# To solve this issue here, we set all videos' timebase to be same as the longest video's timebase
