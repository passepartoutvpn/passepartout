#!/bin/sh
if [ -z $1 ]; then
    echo "Version number required"
    exit 1
fi
if [ ! -z $2 ]; then
    BUILD="build:$2"
fi
VERSION="version:$1"
bundle exec fastlane bump $VERSION $BUILD
