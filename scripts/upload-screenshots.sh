#!/bin/bash
platforms=("iOS macOS tvOS")
if [[ -n "$1" ]]; then
    platforms=("$1")
fi
for platform in $platforms; do
    bundle exec fastlane --env secret,$platform asc_screenshots
done
