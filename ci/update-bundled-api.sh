#!/bin/bash
DESTINATION="Passepartout/Library/Sources/CommonLibrary/Resources/API"
API_VERSION="v5"

mkdir tmp
cd tmp
if [[ ! `git clone https://github.com/passepartoutvpn/api --depth 1` ]]; then
    cd api
    git pull
fi
cd ../..

rm -rf $DESTINATION
mkdir -p $DESTINATION
cp -rp tmp/api/$API_VERSION $DESTINATION
