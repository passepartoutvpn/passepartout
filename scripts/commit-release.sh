#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "stable" ]]; then
    echo "Not on stable branch"
    exit
fi

VERSION=`ci/version-number.sh`
DATE=`date "+%Y-%m-%d"`
CHANGELOG_GLOB="Passepartout/App/*/CHANGELOG.md"
sed -i '' -E "s/^.*Beta.*$/## $VERSION ($DATE)/" $CHANGELOG_GLOB
git commit -am "Release" && git tag -as "v$VERSION"
