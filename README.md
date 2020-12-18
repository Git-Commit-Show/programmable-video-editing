# Programmable video editing
## Scripts, tools and resources to automate video editing

### Scripts

1. [autocut: Cut video at specified timestamps](/autocut.sh)  `autocut infile timestamp1 timestamp2 ...`
2. [combine: Combine multiple videos into one - quite slow but it doesn't have audio/video sync issue](/combine.sh) `combine fileList.txt`
3. [removeduplicateframes: Reduce frame rate and size by removing duplicate frames](/removeduplicateframes.sh) `removeduplicateframes mybigvideofile.mp4`

Additional scripts for advanced use

4. [combinevideos: Combine multiple videos into one (fast but works only when all files format, timescale and fps are same)](/combinevideos.sh) `combinevideos fileList.txt`
5. [recordscreen: Record screen using ffmpeg](/recordscreen.sh) `recordscreen`

**How to use scripts on linux/ubuntu**

1. Download the scripts and go to your terminal
2. Open `~/.bashrc` with command `sudo gedit ~/.bashrc` (gedit is my favorite editor on linux but you can just use any editor to do what's coming next)
3. Append the content of the script (e.g. content of autocut script) to `~/.bashrc` inside a function as follows
```
autocut() {
  #Content of autocut script goes here
}
```
4. Run `source ~/.bashrc`
5. Now you will be able to run the command such as `autocut infilepath timestamp1 timestamp2`

Now, get started with your main source video file and make the first cut by creating a text file such as [this one](./cut_config_sample.md).
Use simple ffmpeg commands to pick one part, use `autocut` to make multiple cuts Use `combine` to combine selected cuts. In the end, use `removeduplicatefreames` to reduce the size of the final video.

**A note for macOS users**

Instructions to use it are the same as linux except the file `~/.bashrc` is usually not there, rather it is `~/.bash_profile` on macOS and the default text editor on macOS is TextEdit instead of gedit. Usually I prefer to use my favorite editors to edit the files and make sure everything is formatted well.
