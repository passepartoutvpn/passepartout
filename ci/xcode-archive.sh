#!/bin/bash
cwd=`dirname $0`
platform=$1
if [ -z $platform ]; then
    echo "Missing platform"
    exit 1
fi
project_name=Passepartout
scheme=Passepartout
configuration=Release
#scheme=PassepartoutMac
#configuration=ReleaseMac
dst="build"
xcodebuild archive \
    -project $project_name.xcodeproj \
    -destination "generic/platform=$platform" \
    -archivePath "$dst/$platform/$project_name.xcarchive" \
    -scheme $scheme \
    -configuration $configuration
