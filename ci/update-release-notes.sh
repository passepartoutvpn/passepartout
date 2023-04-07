#!/bin/bash
. .env.$1

RELEASE_NOTES="$DELIVER_METADATA_PATH/en-US/release_notes.txt"

ci/latest-changelog.sh $1 stripped >"$RELEASE_NOTES"
