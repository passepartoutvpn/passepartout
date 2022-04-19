#!/bin/sh
VERSION=$1

if [[ -z $VERSION ]]; then
    echo "Version number required"
    exit 1
fi

CHANGELOG_GLOB="CHANGELOG.md"

ci/set-version.sh $VERSION
sed -i '' -E "s/(^and this project adheres.*$)/\1\n\n## Unreleased/" $CHANGELOG_GLOB

git add *.plist $CHANGELOG_GLOB
git commit -m "Bump version"
