############################################################
##                                                        ##
##    WMTU Technology - WMTU 91.9FM - https://wmtu.fm/    ##
##    Script for archiving the radio stream broadcast     ##
##    Ported from the original PHP script by Brady        ##
##                                                        ##
##    Uses ffmpeg for all the fun stuff, run using a      ##
##    cron job every hour!                                ##
##                                                        ##
############################################################

#!/bin/bash

###############################################
## variables used for the rest of the script ##
###############################################

# icecast2 source server
streamserver="https://stream.wmtu.fm"

# icecast2 source port
streamport="8000"

# icecast2 stream mount point
streammount="wmtu-live"

# location to save the archived mp3 file to
archiveroot="/var/www/archive"

# the times that we should record in
# hours are in in military time
times=(0 1 3 5 7 8 10 12 14 16 18 20 22)


################################################
## everything after this is the actual script ##
################################################

# get the current date and time
day=$(date -d 'now + 1 hour' +%A)
hour=$(date -d 'now + 1 hour' +%H)
showtime=$(date -d 'now + 1 hour' +%I%p)
filename="WMTU $(date -d 'now + 1 hour' +%Y.%m.%d\ %I%p).mp3"
timestamp="[$(date -d 'now + 1 hour' +%x\ %H\ %l%p)]"

# debug log flag
debug=0

# set the correct record duration
# some hours only record for 1 hour, most record for 2 hours
# the hours are in military time
if [ $hour -eq 0 ] || [ $hour -eq 7 ]
then
    duration=1
else
    duration=2
fi

# check if the hour is an hour to record in
record=0
for item in ${times[@]}
do
    [[ $item -eq $((10#$hour)) ]] && record=1
done

# if record is true then record
if [ $record -eq 1 ]
then
    # check for a directory for the current day
    if [ ! -d $archiveroot/$day ]
    then
        mkdir -p $archiveroot/$day
    fi

    # check for a file for the current showtime
    # this will remove the archive from previous dates,
    # and also an archive that might exist for the current hour
    filecount=$(ls -1 $archiveroot/$day/ | grep $showtime | wc -l)
    if [ $filecount -gt 0 ]
    then
        rm $archiveroot/$day/WMTU*$showtime.mp3
        [[ $debug -eq 1 ]] && echo "$timestamp rm $archiveroot/$day/WMTU*$showtime.mp3" >> /opt/archiving/debug.txt
    fi

    # for debugging purposes
    [[ $debug -eq 1 ]] && echo "$timestamp ffmpeg -hide_banner -i $streamserver/$streammount -f mp3 -t $duration:10:00 -acodec copy $archiveroot/$day/$filename" >> /opt/archiving/debug.txt

    # rip our mp3 file
    ffmpeg -hide_banner -i $streamserver/$streammount -f mp3 -t $duration:10:00 -acodec copy "$archiveroot/$day/$filename"
else
    # for debugging purposes
    [[ $debug -eq 1 ]] && echo "$timestamp Not recording now" >> /opt/archiving/debug.txt
fi

exit
