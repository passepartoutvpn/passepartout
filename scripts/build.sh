#!/bin/sh
rm -rf build dist
scripts/commit-beta.sh
ci/beta-archive.sh mac || { echo "Failed to build macOS" ; exit 1 ; }
scripts/reset-archive.sh
ci/beta-archive.sh ios || { echo "Failed to build iOS" ; exit 1 ; }
scripts/reset-archive.sh
