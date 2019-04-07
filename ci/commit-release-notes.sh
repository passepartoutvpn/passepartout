#!/bin/sh
TARGET="fastlane/metadata/en-US/release_notes.txt"
ci/latest-changelog.sh | sed -E "s/^(.*) \[#.*$/\1/" >$TARGET
git add $TARGET
git commit -m "Update release notes (en)"
