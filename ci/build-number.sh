#!/bin/sh
cwd=`dirname $0`
xcodeproj="$cwd/../Passepartout.xcodeproj/project.pbxproj"
$cwd/xcode-get-setting.sh $xcodeproj CURRENT_PROJECT_VERSION "([0-9]+)"
