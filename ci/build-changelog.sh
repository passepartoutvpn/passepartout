#!/bin/bash
. .env
. .env.$1

RELEASE_NOTES="$DELIVER_METADATA_PATH/en-US/release_notes.txt"
if [[ -n $CHANGELOG_PREFACE ]]; then
    echo "$CHANGELOG_PREFACE"
    echo
fi
cat $RELEASE_NOTES
