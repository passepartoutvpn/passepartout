#!/bin/sh
VERSION=$1
if [[ -z $VERSION ]]; then
    echo "Must provide version"
    exit 1
fi

APP_ROOT="Passepartout/App"
echo "# App Store"
echo
grep $VERSION $APP_ROOT/iOS/CHANGELOG.md | cut -f 2- -d " "
echo
echo "## iOS"
echo
cat $APP_ROOT/iOS/fastlane/metadata/en-US/release_notes.txt
echo "## macOS"
echo
cat $APP_ROOT/macOS/fastlane/metadata/en-US/release_notes.txt
