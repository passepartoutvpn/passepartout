#!/bin/bash
cwd=`dirname $0`
name="Passepartout"
arch="$1"
if [[ -z "$arch" ]]; then
    echo "Missing arch"
    exit 1
fi
version=`$cwd/version-number.sh`
volname="$name $version $arch"
srcfolder="$cwd/dmg"
dmg="$name.$arch.dmg"

echo "Copy .app to .dmg contents..."
cp -RH "dist/macOS/$name.app" "$srcfolder"

echo "Create $volname..."
hdiutil create \
    -volname "$volname" \
    -srcfolder "$srcfolder" \
    -ov -format UDZO \
    "$dmg"
