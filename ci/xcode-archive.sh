#!/bin/bash
cwd=`dirname $0`
platform=$1
developer_id=$2
if [[ -z $platform ]]; then
    echo "Missing platform"
    exit 1
fi
project_name=Passepartout
scheme=Passepartout
configuration=Release
if [[ $developer_id == 1 ]]; then
    scheme=PassepartoutMac
    configuration=ReleaseMac
fi
dst="build"
xcodebuild archive \
    -project $project_name.xcodeproj \
    -destination "generic/platform=$platform" \
    -archivePath "$dst/$platform/$project_name.xcarchive" \
    -scheme $scheme \
    -configuration $configuration
