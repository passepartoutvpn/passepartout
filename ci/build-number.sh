#!/bin/sh
cwd=`dirname $0`
xcconfig="$cwd/../Passepartout/Config.xcconfig"
$cwd/xcconfig-get.sh $xcconfig CURRENT_PROJECT_VERSION "([0-9]+)"
