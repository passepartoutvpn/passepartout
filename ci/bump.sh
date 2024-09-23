#!/bin/sh
if [ ! -z $1 ]; then
    VERSION="version:$1"
fi
bundle exec fastlane bump "$VERSION"
