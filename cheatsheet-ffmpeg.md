## Useful ffmpeg commands for common video editing tasks

### Cutting video

**From time 00:03 to 00:06 without reencoding(fast)**

`ffmpeg -i infile.mp4 -ss 00:03 -to 00:06 -c copy outfile.mp4`


### Merging multiple videos in one file

```
ffmpeg -f concat -i filesToJoin.txt combined.mp4
// filesToJoin.txt content
// file infile1.mp4
// file infile2.mp4

```


### Converting file to another format

**mov to mp4**

`ffmpeg -i infile.mov outfile.mp4`


**Convert video to GIF**

The dirty way 
`ffmpeg -i infile.mp4 -vf "fps=10,scale=320:-2:flags=lanczos" outfile.gif`

> GIF color issues might be there as gif has only 256 color pallette. To create better gif, [first create color pallette and use that to create gif](https://medium.com/abraia/basic-video-editing-for-social-media-with-ffmpeg-commands-1e873801659).


### Overlay

**Overlay a logo**

`ffmpeg -i video_clip.mp4 -i logo.png -filter_complex "overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" video.mp4`


### Creating video preview

**Using [ffmpeg-generate-video-preview](https://github.com/transitive-bullshit/ffmpeg-generate-video-preview) to create screenshots collage**

`generate-video-preview infile.mp4 previewCollage.jpg --width 160 --rows 5 --cols 6 --padding 4 --margin 4`


### References

0. [Learn ffmpeg the hard way](https://github.com/leandromoreira/ffmpeg-libav-tutorial)
1. [ffmpeg for social media](https://medium.com/abraia/basic-video-editing-for-social-media-with-ffmpeg-commands-1e873801659)
2. [awesome-ffmpeg](https://github.com/transitive-bullshit/awesome-ffmpeg)
3. [editly : minimal command line video editing](https://github.com/mifi/editly) 
4. [vidgear; video processing with access to multiple libraries e.g. opencv, ffmpeg](https://github.com/abhiTronix/vidgear)
5. [auto-motion](https://github.com/teamxenox/auto-motion)
6. [scripts](https://gitlab.com/dak425/scripts) by [donald feury](https://medium.com/@highlordazurai425/how-i-completely-automated-my-youtube-editing-5748c0e08b9d)
7. [some ffmpeg video editing commands](https://viveksb007.github.io/2017/12/ffmpeg-automate-filtering-and-editing-videos)
8. [seeking in ffmpeg](http://trac.ffmpeg.org/wiki/Seeking)
9. [concatenate videos in ffmpeg](https://trac.ffmpeg.org/wiki/Concatenate)
10. [deinterlacing algo in ffmpeg](https://ffmpeg.org/ffmpeg-filters.html#yadif-1)
11. [preset ffmpeg](http://ffmpeg.org/ffmpeg.html#Preset-files)
12. [.ass subtitles ffmpeg](http://ffmpeg.org/ffmpeg.html#ass)
13. [ffmpeg cheatsheet by steven2358](https://gist.github.com/steven2358/ba153c642fe2bb1e47485962df07c730)
