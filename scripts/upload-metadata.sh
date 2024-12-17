#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

if [[ -n "$1" ]]; then
    platforms="$1"
fi
for platform in $platforms; do
    bundle exec fastlane --env secret,$platform asc_metadata
done
