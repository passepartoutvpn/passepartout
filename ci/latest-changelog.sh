#!/bin/bash
. .env.$1

RELEASES=(`grep -n "^## " $CHANGELOG | sed -E "s/^([0-9]+).*$/\1/g"`)
UNRELEASED=${RELEASES[0]}
LATEST=${RELEASES[1]}

if [ ! $LATEST ]; then
    LATEST=`cat $CHANGELOG | wc -l`
    cat $CHANGELOG | tail -n $((LATEST - UNRELEASED - 1))
    exit
fi

if [ "$2" = "stripped" ]; then
    SED_STRIPPED="sed -E 's/^(.*)\. \[.*$/\1./'"
else
    SED_STRIPPED="cat"
fi

cat $CHANGELOG | head -n $((LATEST - 1)) | tail -n $((LATEST - UNRELEASED - 2)) | eval $SED_STRIPPED
