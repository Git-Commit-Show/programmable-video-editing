#!/bin/bash

# Combine multiple videos to create one single video
# Input : combinevideos file_containing_list_of_files.txt
# Structure of file_containing_list_of_files.txt is as follows \/
# file myfile1.mp4
# file myfile2.mp4 ...

## How it works
## 1. Convert videos to intermediary format(Quicktime container MTS)
## ffmpeg -i clip.flv -q 0 clip.MTS
## ffmpeg -i intro.flv -q 0 intro.MTS
## ffmpeg -i outro.flv -q 0 outro.MTS
## 2. Combine these videos
## //filesToJoin.tx : file intro.MTS \n file clip.MTS \n file outro.MTS
## ffmpeg -f concat -i filesToJoin.txt -c copy output.MTS
## 3. ffmpeg -f concat -i filesToJoin.txt -c copy output.MTS
## 4. Convert format of output.MTS to .mp4
## ffmpeg -i output.MTS -q 0 intro.mp4

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
timescale_of_largest_video=0;
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
  timescale=$(ffprobe -loglevel warning -show_streams $filepath | awk '/^time_base/' | awk -F\= '{ "basename "$1"" |& getline $1; print $2;exit}'|awk -F\/ '{print $2}')
  duration=$(ffprobe -loglevel warning -v error -show_entries format=duration  -of default=noprint_wrappers=1:nokey=1 $filepath)
  echo "${count}: $filepath ; duration: $duration s; time_base: $timescale"
  count=$[$count+1]
  #Find the longest video and remeber it's timescale
  if [ $(float_gt $duration $largest_duration) == 1 ]
  then
  	largest_duration=$duration
        timescale_of_largest_video=$timescale
        longest_video="$filepath"
  fi
  #finalfilepath generation: apending all file names except when filename exceeds 30 characters
  if [ ${#finalfilepath} -lt 30 ]
  then
	finalfilepath="${finalfilepath}_$base"
  fi
done < "$FILE_LIST"

finalmtsfilepath="${finalfilepath}.MTS"
finalfilepath="${finalfilepath}.mp4"

echo ""
echo -e "\e[1mLongest video is $longest_video\e[0m with duration: $largest_duration and \e[1mtimescale: $timescale_of_largest_video\e[0m"
echo ""

#Step 1 : Fix the time_base of all videos(why? detail in the references section of this script)
#newfilearray=()
#settimescale(){	
#  timescale=$(ffprobe -loglevel warning -show_streams $1 | awk '/^time_base/' | awk -F\= '{ "basename "$1"" |& getline $1; print $2;exit}'|awk -F\/ '{print $2}')
  #if timescale is different than what we want to fix, create a temporary video with new timescale
#  if [ $timescale -ne $2 ]
#  then
#	  tmp_filename="tmp_${2}_$1"
#	  echo -e "\e[7mChanging timescale for file: $1 from $timescale to $2 tbn and saving new file at $tmp_filename\e[0m"
#	  ffmpeg -loglevel warning -i $1 -video_track_timescale $2 $tmp_filename
#          newfilearray+=("$tmp_filename")
#  else
#	newfilearray+=("$1")
#  fi
#}

mtsfilearray=()
convertToMTS(){	
  base=$(echo $1 | sed 's/\.[^.]*$//')
  mtsfilepath="$base.MTS"
  mtsfilearray+=("$mtsfilepath")
  ffmpeg -i $1 -q 0 $mtsfilepath
}

for i in ${!filearray[@]}; do
#  settimescale ${filearray[$i]} $timescale_of_largest_video
   convertToMTS ${filearray[$i]}
done

#create a new text file to store all file names that we want to concat
newfilelistwithsyncdtimescale="tmp_combine_file_list"

#commented in favor of converting to mts first approach
#for i in ${!newfilearray[@]}; do
#  filepath="${newfilearray[$i]}"
#  base=$(echo $filepath | sed 's/\.[^.]*$//')
#  newfilelistwithsyncdtimescale="${newfilelistwithsyncdtimescale}_$base" 
#done

for i in ${!mtsfilearray[@]}; do
  echo "New MTS File : ${mtsfilearray[$i]}"
  filepath="${mtsfilearray[$i]}"
  base=$(echo $filepath | sed 's/\.[^.]*$//')
  newfilelistwithsyncdtimescale="${newfilelistwithsyncdtimescale}_$base" 
done


newfilelistwithsyncdtimescale="${newfilelistwithsyncdtimescale}.txt" 

if [ ! -f "$newfilelistwithsyncdtimescale" ]
then
	echo "Creating file ${newfilelistwithsyncdtimescale}"
	touch $newfilelistwithsyncdtimescale
else
	echo "File '${newfilelistwithsyncdtimescale}' already exists"
	echo -n "Do you want to proceed further (y/n)? "
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
   	   > "$newfilelistwithsyncdtimescale"
	else
           echo  "Quitting..."
	   exit
	fi
fi

#for i in ${!newfilearray[@]}; do
#  echo "file ${newfilearray[$i]}" >> $newfilelistwithsyncdtimescale
#done

for i in ${!mtsfilearray[@]}; do
  echo "file ${mtsfilearray[$i]}" >> $newfilelistwithsyncdtimescale
done

while IFS= read -r line
do 
    echo "$line"
done < "$newfilelistwithsyncdtimescale"

echo ""
echo "Preparing output $finalmtsfilepath"
echo ""

# Now that all the files have commmon encoding
#Step 2: concatenate the files using the updated list of files
#ffmpeg -f concat -safe 0 -i $newfilelistwithsyncdtimescale -copytb 0 -c copy -loglevel warning $finalmtsfilepath 
ffmpeg -f concat -i $newfilelistwithsyncdtimescale -c copy $finalmtsfilepath

echo ""
echo "Preparing output $finalfilepath"
echo ""

#Step 3: Convert intermediary format to .mp4 format
ffmpeg -i $finalmtsfilepath -q 0 $finalfilepath

# References
# -loglevel warning for less verbose command print
# -c copy to skip encoding the videos again

# ISSUE: DTS out of order https://stackoverflow.com/a/56002050/7360184 (unexpected output when encoding does not match)
# To solve this issue here, we set all videos' timescale to be same as the longest video's timescale
