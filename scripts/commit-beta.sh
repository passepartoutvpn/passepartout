#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi

ci/update-changelog.sh ios
ci/update-changelog.sh mac
git add Passepartout/App/*/CHANGELOG.md
git add Passepartout/App/*/fastlane/metadata/*/release_notes.txt
git commit -m "Set beta release"

VERSION=`agvtool mvers -terse1`
BUILD=`agvtool vers -terse`

# predict build number (add commits count)
HISTORY=`git rev-list --count HEAD`
BUILD=$((BUILD + HISTORY))

git tag "v$VERSION-b$BUILD"
