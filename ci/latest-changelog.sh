#!/bin/sh
TARGET="CHANGELOG.md"
RELEASES=(`grep -n "^## " $TARGET | sed -E "s/^([0-9]+).*$/\1/g"`)
UNRELEASED=${RELEASES[0]}
LATEST=${RELEASES[1]}
cat $TARGET | head -n $((LATEST - 1)) | tail -n $((LATEST - UNRELEASED - 2))
