#!/bin/bash
. .env.$1

RELEASE_NOTES="$DELIVER_METADATA_PATH/en-US/release_notes.txt"
STRIPPED_ISSUES_SUB="s/^(.*)\. \[.*$/\1./"

ci/latest-changelog.sh $1 | sed -E "$STRIPPED_ISSUES_SUB" >"$RELEASE_NOTES"
