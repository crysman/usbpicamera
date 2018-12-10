#!/bin/bash
# simple timelapse - captures pictures from default connected USB camera device (/dev/video0 ?)
# and stores them as jpegs in separate directories using streamer
# crysman (copyleft) 2018

DIRNAME=`dirname "$0"`
SUBDIRNAME="camimages"
fps="0.06"

function eErr {
  timestamp=`date -Iseconds`
  echo "ERR: $1" >&2
  echo "[$timestamp] ERR: $1" >> "$DIRNAME"/usbpicamera.log
  exit 1
}

function eLog {
  timestamp=`date -Iseconds`
  echo "INFO: $1"
  echo "[$timestamp] INFO: $1" >> "$DIRNAME"/usbpicamera.log
}

#do we have enough space?
spaceTaken=`df -P | grep "/$" | awk '{print $5}' | tr -d "%"`
test $spaceTaken -gt 95 && {
  eErr "not enough free space on /"
}

#do we have camimages subdirectory?
#test -d "camimages"  || mkdir -p "$DIRNAME/camimages"

#do we have streamer? we need it...
which streamer >/dev/null 2>&1 || eErr "streamer not installed, exitting... (try 'sudo apt install streamer')"

#into which folder to store images?
oneRandomChar=`head /dev/urandom | tr -dc A-Za-z | head -c 1`
#adding one random char in case of system time being the same (e.g. no internet connection to sync time)
folderName=`date '+%Y%m%d-%H%M%S'`$oneRandomChar
fileName=`date '+%Y%m%d-%H%M'`_00.jpeg
mkdir -p "$DIRNAME/$SUBDIRNAME/$folderName"

#let's capture them...
#framerate -r 0.06 = once every 10 sec
eLog "trying to start capturing on $fps into $DIRNAME/$SUBDIRNAME/$folderName"
streamer -t "23:59:59" -r "$fps" -s 1280x720 -j 95 -o "$DIRNAME/$SUBDIRNAME/$folderName/$fileName"
