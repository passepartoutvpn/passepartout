#!/bin/sh
cwd=`dirname $0`
platforms="iOS macOS tvOS"
if [[ -n "$1" ]]; then
    platforms=("$1")
fi
changelog="$cwd/../CHANGELOG.txt"
metadata_root="$cwd/../fastlane/metadata"
metadata_path="default/release_notes.txt"
for platform in $platforms; do
    release_notes="$metadata_root/$platform/$metadata_path"
    rm -f "$release_notes"
    cp "$changelog" "$release_notes"
done
