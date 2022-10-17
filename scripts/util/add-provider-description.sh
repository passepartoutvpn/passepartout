#!/bin/bash
PATTERN="Passepartout/App/fastlane/ios/metadata/*/description.txt"
AFTER=$1
NAME=$2
DELIMITER="†"

for FILE in `ls $PATTERN`; do
    sed -E "s/${AFTER}/${AFTER}${DELIMITER}- ${NAME}/g" $FILE | tr $DELIMITER '\n' >$FILE.tmp
    mv $FILE.tmp $FILE
done
