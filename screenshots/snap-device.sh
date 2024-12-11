#!/bin/bash
cwd=`dirname $0`
device=$1
snap_cmd="$cwd/snap.sh"
fastlane_screenshots_root="$cwd/../fastlane/screenshots"

case $device in

  "iphone")
    nums=("01 02 03 04 05")
    template="main"
    width=1242
    height=2688
    fastlane="iOS"
    ;;

  "ipad")
    nums=("01 02 03 04 05")
    template="main"
    width=2048
    height=2732
    fastlane="iOS"
    ;;

  "mac")
    nums=("01 02 03 04 05")
    template="main"
    width=2880
    height=1800
    fastlane="macOS"
    ;;

  "appletv")
    nums=("01 02 03")
    template="tv"
    width=3840
    height=2160
    fastlane="tvOS"
    ;;

  *)
    echo "Unknown device: $device"
    exit 1
    ;;
esac

for num in $nums; do
    $snap_cmd $template $device $num $width $height "$fastlane_screenshots_root/$fastlane/en-US"
done
