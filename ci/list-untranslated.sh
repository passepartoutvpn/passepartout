#!/bin/sh
DIR="Passepartout/Resources"
FILENAME="Localizable.strings"
STRINGS_EN="$DIR/en.lproj/$FILENAME"
STRINGS_IT="$DIR/it.lproj/$FILENAME"
IDS="string-ids.tmp"

sed -E "s/^(.+) = .*$/\1/" $STRINGS_EN | grep '^"' >$IDS.en
sed -E "s/^(.+) = .*$/\1/" $STRINGS_IT | grep '^"' >$IDS.it
diff $IDS.en $IDS.it | grep "^<" | sed -E 's/^< "(.*)"$/\1/g'
rm -f $IDS.*
