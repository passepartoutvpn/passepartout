#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

if [[ -n "$1" ]]; then
    devices="$1"
fi
for device in $devices; do
    if ! screenshots/export.sh $device; then
        exit 1
    fi
    if ! screenshots/compose-device.sh $device; then
        exit 1
    fi
done
