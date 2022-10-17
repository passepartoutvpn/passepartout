#!/bin/bash
SRC="$1"
DST="$2"
for LANG in "de" "el" "en" "es" "fr" "it" "nl" "pl" "pt" "ru" "sv" "zh-Hans"; do
    cp $SRC/$LANG/* $DST/$LANG.lproj
done
