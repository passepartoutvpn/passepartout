#!/bin/sh
if [[ -z "$1" ]]; then
    echo "Platform required"
    exit 1
fi
platform=$1
bundle exec fastlane match development --env $platform,secret --force_for_new_devices --force
