#!/bin/bash
. .env.$1

CHANGELOG="CHANGELOG.md"
RELEASES=(`grep -n "^## " $CHANGELOG | sed -E "s/^([0-9]+).*$/\1/g"`)
UNRELEASED=${RELEASES[0]}
LATEST=${RELEASES[1]}

if [ ! $LATEST ]; then
    LATEST=`cat $CHANGELOG | wc -l`
    cat $CHANGELOG | tail -n $((LATEST - UNRELEASED - 1))
    exit
fi
cat $CHANGELOG | head -n $((LATEST - 1)) | tail -n $((LATEST - UNRELEASED - 2))
