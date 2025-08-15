#!/bin/bash
dmg="$1"
if [[ -z "$dmg" ]]; then
    echo "Missing volume"
    exit 1
fi
cp -rfp "$dmg/.DS_Store" "$dmg/.background" "ci/dmg"
