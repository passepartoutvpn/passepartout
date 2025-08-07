#!/bin/bash
cwd=`dirname $0`
team_id=`$cwd/team-id.sh`
name="Passepartout"
arch="$1"
apple_id="$2"
apple_password="$3"

if [[ -z "$arch" ]]; then
    echo "Missing arch"
    exit 1
fi
if [[ -z "$apple_id" ]]; then
    echo "Missing Apple ID"
    exit 1
fi
if [[ -z "$apple_password" ]]; then
    echo "Missing Apple ID password"
    exit 1
fi

dmg="$name.$arch.dmg"
set -e

echo "Notarize .dmg..."
xcrun notarytool submit "$dmg" \
    --team-id "$team_id" \
    --apple-id "$apple_id" \
    --password "$apple_password" \
    --wait

echo "Staple .dmg..."
xcrun stapler staple "$dmg"
