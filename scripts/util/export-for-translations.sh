#!/bin/bash
APP_ROOT="Passepartout/App"
APP_SHARED_ROOT="Passepartout/AppShared"

DIST="l10n"
DIST_APP="$DIST/App"
DIST_META="$DIST/Meta"
OUTPUT="passepartout-translations.zip"

rm -rf $OUTPUT $DIST
mkdir -p $DIST_APP
mkdir -p $DIST_META

if [[ $1 == "all" ]]; then
    cp $APP_SHARED_ROOT/en.lproj/Localizable.strings $DIST_APP/Localizable.txt
    cp $APP_ROOT/Intents/en.lproj/Intents.strings $DIST_APP/Intents.txt
    cp $APP_ROOT/en.lproj/InfoPlist.strings $DIST_APP/InfoPlist.txt

    cp $APP_ROOT/fastlane/ios/metadata/en-US/name.txt $DIST_META
    cp $APP_ROOT/fastlane/ios/metadata/en-US/subtitle.txt $DIST_META
    cp $APP_ROOT/fastlane/ios/metadata/en-US/description.txt $DIST_META
elif [[ $2 == "new" ]]; then
    grep -f templates/new-strings.txt $APP_SHARED_ROOT/en.lproj/Localizable.strings >$DIST_APP/Localizable.txt
    grep -f templates/new-strings.txt $APP_ROOT/en.lproj/Intents.strings >$DIST_APP/Intents.txt
    grep -f templates/new-strings.txt $APP_ROOT/en.lproj/InfoPlist.strings >$DIST_APP/InfoPlist.txt
else
    echo "No argument given (all|new)"
    exit
fi

cp templates/iaps.txt $DIST/Products.txt
zip -r $OUTPUT $DIST
