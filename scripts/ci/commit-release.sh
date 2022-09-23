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

DATE=`date "+%Y-%m-%d"`
CHANGELOG_GLOB="CHANGELOG.md"
COMMIT_MESSAGE="[ci skip] Set release date"
TAG_MESSAGE="Release"
sed -i'' -E "s/^.*Unreleased.*$/## $VERSION ($DATE)/" $CHANGELOG_GLOB

if ! git commit -am "$COMMIT_MESSAGE"; then
    echo "Failed to commit release"
    git reset --hard
    exit 1
fi

if ! git tag -a "v$VERSION" -m "$TAG_MESSAGE"; then
    echo "Failed to tag release"
    git reset --hard HEAD^
    exit 1
fi
