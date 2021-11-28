#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi

VERSION=`ci/version-number.sh ios`
DATE=`date "+%Y-%m-%d"`
CHANGELOG_GLOB="Passepartout/App/*/CHANGELOG.md"
COMMIT_MESSAGE="Set release date"
TAG_MESSAGE="Release"
TAG_SIGN="--sign"
if [[ $1 == "no-sign" ]]; then
    TAG_SIGN=""
fi
sed -i '' -E "s/^.*Beta.*$/## $VERSION ($DATE)/" $CHANGELOG_GLOB

if ! git commit -am "$COMMIT_MESSAGE"; then
    echo "Failed to commit release"
    git reset --hard
    exit
fi

if ! git tag $TAG_SIGN -a "v$VERSION" -m "$TAG_MESSAGE"; then
    echo "Failed to tag release"
    git reset --hard HEAD^
    exit
fi
