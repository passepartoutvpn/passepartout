#!/bin/sh
platforms="iOS macOS tvOS"
if [[ -n "$1" ]]; then
    platforms=("$1")
fi
changelog="CHANGELOG.txt"
for platform in $platforms; do
    release_notes="fastlane/metadata/$platform/default/release_notes.txt"
    rm -f "$release_notes"
    cp "$changelog" "$release_notes"
done
