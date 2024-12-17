#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

if [[ -n "$1" ]]; then
    devices="$1"
fi
for device in $devices; do
    screenshots/export.sh $device
    screenshots/compose-device.sh $device
done
