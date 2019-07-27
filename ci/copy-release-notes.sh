#!/bin/sh
METADATA="release_notes"
RX='^[a-z]{2}(\-[A-z]+)?$'
cd fastlane/metadata
for LANG in `ls -d *`; do
    if [[ $LANG == "en-US" ]]; then
        continue
    fi
    if [[ ! $LANG =~ $RX ]]; then
        continue
    fi
    #echo $LANG
    cp en-US/$METADATA.txt $LANG
done
