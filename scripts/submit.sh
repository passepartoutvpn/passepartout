#!/bin/sh
ci/store-deploy.sh mac || { echo "Failed to deploy macOS" ; exit 1 ; }
ci/store-deploy.sh ios || { echo "Failed to deploy iOS" ; exit 1 ; }
