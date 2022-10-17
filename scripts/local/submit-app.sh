#!/bin/bash
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
OUTPUT_DIRECTORY="dist/$PLATFORM"
if [[ $PLATFORM == "ios" ]]; then
    export PILOT_IPA="$OUTPUT_DIRECTORY/Passepartout.ipa"
else
    export PILOT_PKG="$OUTPUT_DIRECTORY/Passepartout.pkg"
fi
export CHANGELOG_PREFACE=`cat templates/CHANGELOG.preface.md`
export PILOT_CHANGELOG=`ci/build-changelog.sh $PLATFORM`
bundle exec fastlane --env $PLATFORM,beta,secret run pilot
