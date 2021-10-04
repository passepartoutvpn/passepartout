#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi

VERSION=`ci/version-number.sh`
DATE=`date "+%Y-%m-%d"`
CHANGELOG_GLOB="Passepartout/App/*/CHANGELOG.md"
sed -i '' -E "s/^.*Beta.*$/## $VERSION ($DATE)/g" $CHANGELOG_GLOB
git commit -am "Release" && git tag -as "v$VERSION"
