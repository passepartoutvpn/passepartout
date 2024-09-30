#!/bin/sh
if [ ! -z $1 ]; then
    BUILD="build:$1"
fi
bundle exec fastlane bump $BUILD only:true
