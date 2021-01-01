#!/bin/sh
. .env

DIST="l10n"
DIST_APP="$DIST/App"
DIST_META="$DIST/Meta"
OUTPUT="passepartout-translations.zip"

rm -rf $OUTPUT $DIST
mkdir -p $DIST_APP
mkdir -p $DIST_META

if [[ $1 == "all" ]]; then
    cp Submodules/Core/Passepartout/Resources/en.lproj/Core.strings $DIST_APP/Core.txt
    cp Submodules/Core/Passepartout/Resources/en.lproj/Intents.strings $DIST_APP/Intents.txt
    cp $PROJECT/Global/en.lproj/App.strings $DIST_APP/App.txt
    cp $PROJECT/en.lproj/InfoPlist.strings $DIST_APP/InfoPlist.txt

    cp fastlane/metadata/en-US/name.txt $DIST_META
    cp fastlane/metadata/en-US/subtitle.txt $DIST_META
    cp fastlane/metadata/en-US/description.txt $DIST_META
elif [[ $1 == "new" ]]; then
    grep -f templates/new-strings.txt Submodules/Core/Passepartout/Resources/en.lproj/Core.strings >$DIST_APP/Core.txt
    grep -f templates/new-strings.txt Submodules/Core/Passepartout/Resources/en.lproj/Intents.strings >$DIST_APP/Intents.txt
    grep -f templates/new-strings.txt $PROJECT/Global/en.lproj/App.strings >$DIST_APP/App.txt
    grep -f templates/new-strings.txt $PROJECT/en.lproj/InfoPlist.strings >$DIST_APP/InfoPlist.txt
else
    echo "No argument given (all|new)"
    exit
fi

cp templates/iaps.txt $DIST/Products.txt
zip -r $OUTPUT $DIST
