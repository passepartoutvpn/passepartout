#!/bin/sh
cwd=`dirname $0`
xcconfig="$cwd/../Passepartout/Config.xcconfig"
$cwd/xcconfig-get.sh $xcconfig MARKETING_VERSION
