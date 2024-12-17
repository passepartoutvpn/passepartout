#!/bin/bash
SOURCE=".api"
DESTINATION="Library/Sources/CommonAPI/API"
API_VERSION="v5"

rm -rf $SOURCE
git clone https://github.com/passepartoutvpn/api --depth 1 $SOURCE

rm -rf $DESTINATION
mkdir -p $DESTINATION
mv $SOURCE/$API_VERSION $DESTINATION
rm -rf $SOURCE
