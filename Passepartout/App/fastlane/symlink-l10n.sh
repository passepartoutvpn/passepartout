#!/bin/bash
LANGUAGE=$1
FILELIST="apple_tv_privacy_policy.txt description.txt keywords.txt marketing_url.txt name.txt privacy_url.txt promotional_text.txt subtitle.txt support_url.txt"
IOS_DIR=../../../ios/metadata
cd $LANGUAGE
rm *.txt
for FILENAME in $FILELIST; do
    ln -s "$IOS_DIR/$LANGUAGE/$FILENAME"
done
