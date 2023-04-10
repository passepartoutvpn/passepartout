#!/bin/bash
VERSION=$1
if [[ -z $VERSION ]]; then
    echo "Must provide version"
    exit 1
fi

APP_ROOT="Passepartout/App"
echo "# App Store"
echo
grep -E "$VERSION \(" CHANGELOG.md | cut -f 2- -d " "
echo
ci/latest-changelog.sh ios
