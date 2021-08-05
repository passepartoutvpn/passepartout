#!/bin/sh
SRC="$1"
DST="$2"
for LANG in "de" "el" "en" "es" "fr" "it" "nl" "pl" "ru" "sv" "zh-Hans"; do
    cp $SRC/$LANG/* $DST/$LANG.lproj/*
done
cp $SRC/pt-PT/* $DST/pt.lproj/*
