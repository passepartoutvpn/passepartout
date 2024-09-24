#!/bin/sh
XCODEPROJ="$(dirname "$0")/../Passepartout.xcodeproj/project.pbxproj"
grep MARKETING_VERSION $XCODEPROJ | uniq | sed -E "s/^.*MARKETING_VERSION = ([0-9]\.[0-9]\.[0-9]);/\1/" | tr -d '\n'
