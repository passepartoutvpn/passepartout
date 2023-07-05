#!/bin/bash
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit 1
fi
VERSION=$1
if [[ -z $VERSION ]]; then
    echo "Must provide version"
    exit 1
fi

TAG_MESSAGE="Release"

if ! git tag -a "v$VERSION" -m "$TAG_MESSAGE"; then
    echo "Failed to tag release"
    exit 1
fi
