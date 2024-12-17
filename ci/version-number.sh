#!/bin/sh
cwd=`dirname $0`
xcodeproj="$cwd/../Passepartout.xcodeproj/project.pbxproj"
$cwd/xcode-get-setting.sh $xcodeproj MARKETING_VERSION "([0-9]\.[0-9]\.[0-9])"
