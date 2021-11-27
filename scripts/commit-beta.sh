#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi

ci/update-changelog.sh ios &&
    ci/update-changelog.sh mac &&
    ci/copy-release-notes.sh ios &&
    ci/copy-release-notes.sh mac

git -C PassepartoutCore/Sources/PassepartoutCore/API pull origin master
git add */PassepartoutCore/API
git add Passepartout/App/*/CHANGELOG.md
git add Passepartout/App/*/fastlane/metadata/*/release_notes.txt
git commit -m "Set beta release"

VERSION=`ci/version-number.sh ios`
BUILD=`ci/build-number.sh ios`
git tag "v$VERSION-b$BUILD"
