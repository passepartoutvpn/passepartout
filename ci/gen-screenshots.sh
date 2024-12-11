#!/bin/bash
cwd=`dirname $0`
devices=("iphone ipad mac appletv")
for device in $devices; do
    $cwd/../screenshots/export.sh $device
    $cwd/../screenshots/compose-device.sh $device
done
