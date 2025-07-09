#!/bin/bash
cwd=`dirname $0`
name="Passepartout"
arch="$1"
is_template="$2"
if [[ -z "$arch" ]]; then
    echo "Missing arch"
    exit 1
fi

version=`$cwd/version-number.sh`
volname="$name $version $arch"
srcfolder="$cwd/dmg"
dmg="$name.$arch"

set -e

echo "Copy .app to .dmg contents..."
cp -RH "dist/macOS/$name.app" "$srcfolder"

echo "Create temporary $volname..."
hdiutil create \
    -volname "$volname" \
    -srcfolder "$srcfolder" \
    -fs HFS+ \
    -format UDRW \
    -ov \
    "$dmg.template"

echo "Mount temporary $volname..."
mnt="/Volumes/$volname"
hdiutil attach "$dmg.template.dmg" \
    -mountpoint "$mnt" \
    -readwrite -noautoopen

echo "Reapply .DS_Store..."
cp "$srcfolder/.DS_Store" "$mnt"
chmod 644 "$mnt/.DS_Store"

# stop at template to edit .DS_Store
if [[ -n "$is_template" ]]; then
    exit
fi

echo "Finalize $volname..."
hdiutil detach "$mnt"
hdiutil convert "$dmg.template.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -ov \
    -o "$dmg"
rm "$dmg.template.dmg"
