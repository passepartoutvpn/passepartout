#!/bin/bash
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
export GYM_OUTPUT_DIRECTORY="dist/$PLATFORM"
bundle exec fastlane --env $PLATFORM,beta,secret test_and_build_app test:false
