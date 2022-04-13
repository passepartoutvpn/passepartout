#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit 1
fi

# set build number
BASE_BUILD_NUMBER=`cat .beta-base`
BUILD_FILE=".beta-build"
BUILD=$((BASE_BUILD_NUMBER + `git rev-list HEAD --count` + 1))
ci/set-build.sh $BUILD
echo $BUILD >$BUILD_FILE

# set release notes
ci/update-release-notes.sh ios &&
    ci/update-release-notes.sh mac &&
    ci/copy-release-notes.sh ios &&
    ci/copy-release-notes.sh mac

# pull latest API
API_PATH="PassepartoutCore/Sources/PassepartoutServices/API"
git -C $API_PATH pull origin master
git add $API_PATH

# add build number
git add $BUILD_FILE
git add Passepartout.xcodeproj
git add *.plist

# add release notes
git add Passepartout/App/*/CHANGELOG.md
git add Passepartout/App/*/fastlane/metadata/*/release_notes.txt

git commit -m "Attempt beta release"
#VERSION=`ci/version-number.sh ios`
#git tag "v$VERSION-b$BUILD"
