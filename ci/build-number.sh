#!/bin/sh
XCODEPROJ="$(dirname "$0")/../Passepartout.xcodeproj/project.pbxproj"
grep CURRENT_PROJECT_VERSION $XCODEPROJ | uniq | sed -E "s/^.*CURRENT_PROJECT_VERSION = ([0-9]+);/\1/" | tr -d '\n'
