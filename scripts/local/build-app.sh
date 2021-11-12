#!/bin/sh
PLATFORM=$1
if [[ -z $PLATFORM ]]; then
    echo "Platform required"
    exit
fi
bundle exec fastlane --env $PLATFORM,beta,secret create_archive
