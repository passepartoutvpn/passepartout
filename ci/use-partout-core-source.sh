#!/bin/bash
partout="submodules/partout"
partout_core="vendors/core"

# Local Core submodule
local_core="submodules/partout-core"
local_core_status=`git submodule status $local_core`
local_core_sha1=${local_core_status:1:40}

# Ensure that the Partout submodule is on the same Core version
partout_core_status=`cd $partout && git submodule status $partout_core`
partout_core_sha1=${partout_core_status:1:40}

set -e

echo "Core SHA-1 locally:      $local_core_sha1"
echo "Core SHA-1 in submodule: $partout_core_sha1"
if [ "${local_core_sha1}" != "${partout_core_sha1}" ]; then
    echo "Core SHA-1 in submodule doesn't match local"
    exit 1
fi

# Perform these inside Partout submodule
pushd $partout
env_line_old='let coreDeployment = envCoreDeployment \?\? \.remoteBinary'
env_line_new='let coreDeployment = envCoreDeployment \?\? .localSource'
sed -E -i '' "s/^${env_line_old}$/${env_line_new}/" Package.swift
if ! grep -E -q "^${env_line_new}$" Package.swift; then
    echo "Unable to set Core deployment"
    exit 1
fi
git submodule init $partout_core
git submodule update --depth 1 $partout_core
popd

echo "Updated partout manifest, partout-core -> $local_core_sha1"
