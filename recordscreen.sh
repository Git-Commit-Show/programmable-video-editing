#Script to record screen using ffmpeg

#Get the folder path for videos
videos_folder_path=$(xdg-user-dir VIDEOS)
targetfolder=$(echo $videos_folder_path)

#Create a consistent naming for new files
newfilename=screenrecord_$(echo $(date '+%Y%m%d_%H%M_%S'))
echo "Going to store the new recording at ${targetfolder}/${newfilename}.mp4"

#Record full screen using ffmpeg(assuming screen size is 1920x1080) 
ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 -c:v libx264rgb -crf 0 -preset ultrafast ${targetfolder}/${newfilename}.mp4

#FUTUREWORK- Currently recordWithMic command has some issues
#recordWithMic(){
	#with-sound
#	echo "Recording screen with sound..."
#	ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0+100,200 -f pulse -ac 2 -i default ${targetfolder}/${newfilename}.mp4	
#}
#recordSilent(){
	#without-sound
#	echo "Recording screen without sound..."
#	ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 -c:v libx264rgb -crf 0 -preset ultrafast ${targetfolder}/${newfilename}.mp4
#}

#if [ $# -gt 0 ]; then
#	if [ "$1" = "withmic" ]; then
#		recordWithMic
#	else
#		recordSilent
#	fi
#else
#	recordSilent
#fi	
