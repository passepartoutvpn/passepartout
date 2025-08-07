#!/bin/bash
if [[ -z "$1" ]]; then
    echo "Path to Xcode project required"
    exit 1
fi
if [[ -z "$2" ]]; then
    echo "Setting key required"
    exit 1
fi
xcconfig="$1"
setting_key="$2"
grep ^$setting_key $xcconfig | sed -E "s/^.*${setting_key} = (.*)$/\1/"
