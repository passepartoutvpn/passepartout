#!/bin/sh
VERSION=`ci/version-number.sh`
BUILD=$((`ci/build-number.sh` + 1))
DATE=`date "+%Y-%m-%d"`
CHANGELOG="CHANGELOG.md"
RELEASE_NOTES="fastlane/metadata/en-US/release_notes.txt"

sed "s/Unreleased/$VERSION Beta $BUILD ($DATE)/" $CHANGELOG >$CHANGELOG.tmp
mv $CHANGELOG.tmp $CHANGELOG
ci/latest-changelog.sh | ci/strip-issues.sh >ci/$CHANGELOG
cp ci/$CHANGELOG $RELEASE_NOTES
git add $CHANGELOG $RELEASE_NOTES
git commit -m "Set beta release"
