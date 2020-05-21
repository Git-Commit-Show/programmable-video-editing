#!/bin/bash

# Reduces frame rate by dropping somewhat duplicate frames
# Usage: removeduplicateframes $infile

IN=$1

#To get: filename without extenstion
base=$(echo $IN | sed 's/\.[^.]*$//')
#To get: file extension
ext=$(echo $IN | sed 's@.*\.@@')
newfilename=$(echo "decimated_${base}.${ext}")

ffmpeg -i $IN -vf mpdecimate $newfilename

# We could have usef following setpts; but in our case, it had put audio out of sync
# ffmpeg -i $IN -vf decimate=cycle=6,setpts=N/25/TB $newfilename
# REFERENCE: https://stackoverflow.com/a/52062421/7360184
