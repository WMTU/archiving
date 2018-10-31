archiving
====

About
----

[WMTU Archives](https://archive.wmtu.fm "WMTU Archives")

WMTU creates weekly archives for all of our DJ shows, based on specified time blocks.
This is a faily basic BASH script that runs as a cron job:
```bash
# archiving script, runs every hour
55 * * * * screen -S archive -dma bash /opt/archiving/archiving.sh
```

Dependencies
----

* ffmpeg/avconv
* BASH (or a shell of your choice)

archiving.sh
----

This script has been converted from the previous PHP version, with various improvements and reliability fixes.
It creates MP3 files with easy to read filenames for DJs or community members to download.
