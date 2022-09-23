#!/bin/sh
VERSION=$1
if [[ -z $VERSION ]]; then
    echo "Must provide version"
    exit 1
fi

APP_ROOT="Passepartout/App"
echo "# App Store"
echo
grep $VERSION CHANGELOG.md | cut -f 2- -d " "
echo
echo "## iOS"
echo
cat $APP_ROOT/fastlane/ios/metadata/en-US/release_notes.txt
echo
echo "## macOS"
echo
cat $APP_ROOT/fastlane/mac/metadata/en-US/release_notes.txt
