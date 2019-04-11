#!/bin/sh
DIR="Passepartout/Resources"
FILENAME="Localizable.strings"
LANG_BASE="en"
LANG_TARGET="$1"
STRINGS_BASE="$DIR/$LANG_BASE.lproj/$FILENAME"
STRINGS_TARGET="$DIR/$LANG_TARGET.lproj/$FILENAME"
IDS="string-ids.tmp"

sed -E "s/^(.+) = .*$/\1/" $STRINGS_BASE | grep '^"' >$IDS.$LANG_BASE
sed -E "s/^(.+) = .*$/\1/" $STRINGS_TARGET | grep '^"' >$IDS.$LANG_TARGET
diff $IDS.$LANG_BASE $IDS.$LANG_TARGET | grep "^<" | sed -E 's/^< "(.*)"$/\1/g'
rm -f $IDS.*
