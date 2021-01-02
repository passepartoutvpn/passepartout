#!/bin/sh
. .env.$1

DIST="l10n"
DIST_APP="$DIST/App"
DIST_META="$DIST/Meta"
OUTPUT="passepartout-translations.zip"

rm -rf $OUTPUT $DIST
mkdir -p $DIST_APP
mkdir -p $DIST_META

if [[ $2 == "all" ]]; then
    cp Passepartout/Core/Resources/en.lproj/Core.strings $DIST_APP/Core.txt
    cp Passepartout/Core/Resources/en.lproj/Intents.strings $DIST_APP/Intents.txt
    cp $APP_ROOT/en.lproj/App.strings $DIST_APP/App.txt
    cp $APP_ROOT/en.lproj/InfoPlist.strings $DIST_APP/InfoPlist.txt

    cp $APP_ROOT/fastlane/metadata/en-US/name.txt $DIST_META
    cp $APP_ROOT/fastlane/metadata/en-US/subtitle.txt $DIST_META
    cp $APP_ROOT/fastlane/metadata/en-US/description.txt $DIST_META
elif [[ $2 == "new" ]]; then
    grep -f templates/new-strings.txt Passepartout/Core/Resources/en.lproj/Core.strings >$DIST_APP/Core.txt
    grep -f templates/new-strings.txt Passepartout/Core/Resources/en.lproj/Intents.strings >$DIST_APP/Intents.txt
    grep -f templates/new-strings.txt $APP_ROOT/en.lproj/App.strings >$DIST_APP/App.txt
    grep -f templates/new-strings.txt $APP_ROOT/en.lproj/InfoPlist.strings >$DIST_APP/InfoPlist.txt
else
    echo "No argument given (all|new)"
    exit
fi

cp templates/iaps.txt $DIST/Products.txt
zip -r $OUTPUT $DIST
