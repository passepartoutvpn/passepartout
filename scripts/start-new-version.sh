#!/bin/bash
VERSION_NEXT=$1
if [[ -z $VERSION_NEXT ]]; then
    echo "New version number required"
    exit 1
fi

CHANGELOG_GLOB="CHANGELOG.md"
ci/set-version.sh $VERSION_NEXT
sed -i '' -E "s/(^and this project adheres.*$)/\1\n\n## Unreleased/" $CHANGELOG_GLOB
git add *.plist $CHANGELOG_GLOB
git commit -m "Bump version"
