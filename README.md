# pheed

Supplied a media URL, download the media, process it, add an entry in feed.xml including the source media URL.


If the media is 100 MB or more, reduce filesize.

### Commands Used

  - Download `$url` while converting to mp3 format and downgrading quality to minimize file size `yt-dlp --cookies-from-browser safari -x --audio-format mp3 --audio-quality 8 --restrict-filenames --trim-filenames 65 -o "%(title).150B-[%(id)s].%(ext)s" $url`
  - Get the track time for `$file` to use in XML `ffprobe -i $file -show_entries format=duration -sexagesimal -v quiet -of csv="p=0"`
  - Get the current datetime for use in XML `date -u +'%a, %d %b %Y %T %Z'`

### Apple Podcasts info

  - [Pass-thru URL](https://podcastsconnect.apple.com/my-podcasts/new-feed?submitfeed=https://raw.githubusercontent.com/vinbarnes/pheed/main/feed.xml)
  - [Validate RSS feed](https://podcasters.apple.com/support/829-validate-your-podcast)
  - [Guide to RSS](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)



