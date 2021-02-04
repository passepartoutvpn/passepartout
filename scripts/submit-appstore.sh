#!/bin/sh
ci/store-deploy.sh mac || { echo "Failed to deploy macOS" ; exit 1 ; }
ci/beta-deploy.sh ios || { echo "Failed to deploy iOS" ; exit 1 ; }
scripts/reset-archive.sh

VERSION=`agvtool mvers -terse1`
BUILD=`agvtool vers -terse`
git tag "v$VERSION-b$BUILD"
