#!/bin/sh
DIST="l10n"
DIST_APP="$DIST/App"
DIST_META="$DIST/Meta"
OUTPUT="passepartout-translations.zip"

mkdir -p $DIST_APP
cp Submodules/Core/Passepartout/Resources/en.lproj/Core.strings $DIST_APP/Core.txt
cp Submodules/Core/Passepartout/Resources/en.lproj/Intents.strings $DIST_APP/Intents.txt
cp Passepartout-iOS/Global/en.lproj/App.strings $DIST_APP/App.txt
cp Passepartout-iOS/en.lproj/InfoPlist.strings $DIST_APP/InfoPlist.txt

mkdir -p $DIST_META
cp fastlane/metadata/en-US/name.txt $DIST_META
cp fastlane/metadata/en-US/subtitle.txt $DIST_META
cp fastlane/metadata/en-US/description.txt $DIST_META

cp templates/iaps.txt $DIST/Products.txt

rm -f $OUTPUT
zip -r $OUTPUT $DIST
rm -rf $DIST
