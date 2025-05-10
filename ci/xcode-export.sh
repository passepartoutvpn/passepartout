#!/bin/bash
cwd=`dirname $0`
platform=$1
if [ -z $platform ]; then
    echo "Missing platform"
    exit 1
fi
project_name=Passepartout
team_id=DTDYD63ZX9
src="build"
dst="dist"
tmp_plist="$TMPDIR/options.$platform.plist"

sed "s/CFG_TEAM_ID/$team_id/g" "$cwd/export/options.plist" | \
    sed "s/CFG_PLATFORM/$platform/g" >"$tmp_plist"

xcodebuild -exportArchive \
    -archivePath "$src/$platform/$project_name.xcarchive" \
    -exportPath "$dst/$platform" \
    -exportOptionsPlist "$tmp_plist"

rm "$tmp_plist"
