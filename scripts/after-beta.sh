#!/bin/sh
CHANGELOG_GLOB="Passepartout/App/*/CHANGELOG.md"

sed -i '' -E "s/^.*Beta.*$/## Unreleased/g" $CHANGELOG_GLOB
