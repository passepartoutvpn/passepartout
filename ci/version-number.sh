#!/bin/sh
cwd=`dirname $0`
xcconfig="$cwd/../Passepartout/Config.xcconfig"
$cwd/xcode-get-setting.sh $xcconfig MARKETING_VERSION "([0-9]\.[0-9]\.[0-9])"
