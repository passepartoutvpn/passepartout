#!/bin/sh
if [[ -z "$1" ]]; then
    echo "Platform required"
    exit 1
fi
platform=$1
type=$2
if [[ -z "$type" ]]; then
    type="development"
fi
bundle exec fastlane match $type --env $platform,secret --force_for_new_devices --force
