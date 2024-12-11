#!/bin/sh
CHANGELOG="CHANGELOG.txt"
PLATFORMS="iOS macOS tvOS"

for PLATFORM in $PLATFORMS; do
    DST="fastlane/metadata/$PLATFORM/default/release_notes.txt"
    rm -f "$DST"
    cp "$CHANGELOG" "$DST"
done
