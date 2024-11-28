#!/bin/sh
CHANGELOG="CHANGELOG.txt"
PLATFORMS="iOS macOS tvOS"

for PLATFORM in $PLATFORMS; do
    cp "$CHANGELOG" "fastlane/metadata/$PLATFORM/en-US/release_notes.txt"
done
