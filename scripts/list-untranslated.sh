#!/bin/sh
. .env

DIR_APP="$PROJECT/Global"
FILENAME_APP="App.strings"
DIR_CORE="Submodules/Core/Passepartout/Resources"
FILENAME_CORE="Core.strings"

if [[ $2 = "core" ]]; then
    DIR=$DIR_CORE
    FILENAME=$FILENAME_CORE
else
    DIR=$DIR_APP
    FILENAME=$FILENAME_APP
fi

LANG_BASE="en"
LANG_TARGET="$1"
STRINGS_BASE="$DIR/$LANG_BASE.lproj/$FILENAME"
STRINGS_TARGET="$DIR/$LANG_TARGET.lproj/$FILENAME"
IDS="string-ids.tmp"
TMPOUT="untranslated.tmp"

sed -E "s/^(.+) = .*$/\1/" $STRINGS_BASE | sort | grep '^"' >$IDS.$LANG_BASE
sed -E "s/^(.+) = .*$/\1/" $STRINGS_TARGET | sort | grep '^"' >$IDS.$LANG_TARGET
diff $IDS.$LANG_BASE $IDS.$LANG_TARGET | grep "^<" | sed -E 's/^< "(.*)"$/\1/g' >$TMPOUT
rm -f $IDS.*

grep -f $TMPOUT $STRINGS_BASE
rm $TMPOUT
