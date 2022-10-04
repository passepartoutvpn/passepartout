#!/bin/bash
. .env.$1

RELEASE_NOTES="release_notes"
RX='^[a-z]{2}(\-[A-z]+)?$'
cd "$DELIVER_METADATA_PATH"
for LANG in `ls -d *`; do
    if [[ $LANG == "en-US" ]]; then
        continue
    fi
    if [[ ! $LANG =~ $RX ]]; then
        continue
    fi
    #echo $LANG
    cp en-US/$RELEASE_NOTES.txt $LANG
done
