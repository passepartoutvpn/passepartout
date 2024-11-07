#!/bin/sh
if [ ! -z $1 ]; then
    SINCE="since:$1"
fi
bundle exec fastlane bump $SINCE
