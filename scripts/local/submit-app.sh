#!/bin/sh
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
if [[ $PLATFORM == "ios" ]]; then
    export PILOT_IPA="dist/ios/Passepartout.ipa"
else
    export PILOT_PKG="dist/mac/Passepartout.pkg"
fi
export PILOT_CHANGELOG=`ci/build-changelog.sh $PLATFORM`
bundle exec fastlane --env $PLATFORM,beta,secret store_beta
