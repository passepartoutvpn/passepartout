#!/bin/bash
cwd=`dirname $0`
devices=("iphone ipad mac appletv")
for device in $devices; do
    $cwd/../screenshots/export.sh $device
    $cwd/../screenshots/snap-device.sh $device
done
