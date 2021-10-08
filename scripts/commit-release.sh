#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "stable" ]]; then
    echo "Not on stable branch"
    exit
fi

VERSION=`ci/version-number.sh`
DATE=`date "+%Y-%m-%d"`
CHANGELOG_GLOB="Passepartout/App/*/CHANGELOG.md"
MESSAGE="Release"
sed -i '' -E "s/^.*Beta.*$/## $VERSION ($DATE)/" $CHANGELOG_GLOB

if ! git commit -am $MESSAGE; then
    echo "Failed to commit release"
    git reset --hard
    exit
fi

if ! git tag -as "v$VERSION" -m $MESSAGE; then
    echo "Failed to tag release"
    git reset --hard HEAD^
    exit
fi
