#!/bin/bash
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
export DELIVER_APP_VERSION=`ci/version-number.sh $PLATFORM`
export DELIVER_BUILD_NUMBER=`ci/build-number.sh $PLATFORM`
export DELIVER_FORCE="true"
bundle exec fastlane --env $PLATFORM,secret deliver_review add_id_info_uses_idfa:false

