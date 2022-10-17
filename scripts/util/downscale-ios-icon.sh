#!/bin/bash
SIZES="120 152 167 180 76"

cd Passepartout/App/Assets.xcassets/AppIcon.appiconset
for S in $SIZES; do
    convert -geometry "${S}x${S}" AppIcon-1024.png AppIcon-$S.png
done
