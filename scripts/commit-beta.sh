#!/bin/bash
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit 1
fi

# pull latest API
API_PATH="PassepartoutLibrary/Sources/PassepartoutServices/API"
if ! git -C $API_PATH pull origin master; then
    echo "Could not pull API"
    exit 1
fi
git add $API_PATH

# update bundle
bundle update
git add Gemfile.lock

# set build number
BASE_BUILD_FILE=".beta-base"
BUILD_FILE=".beta-build"
BUILD=$((`cat $BASE_BUILD_FILE` + `git rev-list HEAD --count` + 1))
ci/set-build.sh $BUILD
echo $BUILD >$BUILD_FILE

# set release notes
if [[ $1 != "keep-metadata" ]]; then
    ci/update-release-notes.sh ios && ci/update-release-notes.sh mac
fi
ci/copy-release-notes.sh ios && ci/copy-release-notes.sh mac

# add build number
git add $BASE_BUILD_FILE $BUILD_FILE
git add Passepartout.xcodeproj
git add *.plist

# add release notes
git add CHANGELOG.md
git add Passepartout/App/fastlane/*/metadata/*/release_notes.txt

git commit -m "Attempt beta release"
#VERSION=`ci/version-number.sh ios`
#git tag "v$VERSION-b$BUILD"
