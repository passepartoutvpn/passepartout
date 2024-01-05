#!/bin/bash
SRC="$1"
DST="$2"
LANG_FOLDERS=`cd $DST && ls -d *.lproj`
for FOLDER in $LANG_FOLDERS; do
    LANG="${FOLDER%.lproj}"
    cp $SRC/$LANG/* $DST/$LANG.lproj
done
