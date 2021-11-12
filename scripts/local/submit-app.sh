#!/bin/sh
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
export PILOT_CHANGELOG=`ci/build-changelog.sh $PLATFORM`
bundle exec fastlane --env $PLATFORM,beta,secret store_beta
