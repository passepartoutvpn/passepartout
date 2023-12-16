#!/bin/bash
LANGUAGE=$1
FILENAME="apple_tv_privacy_policy.txt"
IOS_DIR=../../../ios/metadata/en-US
cd $LANGUAGE
rm -f $FILENAME
ln -s "$IOS_DIR/$FILENAME"
