#!/bin/sh
if [ -z "$1" ]; then
    echo "Path to Xcode project required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Setting key required"
    exit 1
fi
if [ -z "$3" ]; then
    echo "Setting regex required"
    exit 1
fi
xcodeproj="$1"
setting_key="$2"
setting_pattern="$3"
grep $setting_key $xcodeproj | sed -E "s/^.*${setting_key} = ${setting_pattern};/\1/" | uniq | tr -d '\n'
