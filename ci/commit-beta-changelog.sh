#!/bin/sh
VERSION=`ci/version-number.sh`
BUILD=$((`ci/build-number.sh` + 1))
DATE=`date "+%Y-%m-%d"`
TARGET="CHANGELOG.md"

sed "s/Unreleased/$VERSION Beta $BUILD ($DATE)/" $TARGET >$TARGET.tmp
mv $TARGET.tmp $TARGET
git add $TARGET
git commit -m "Set beta release"
