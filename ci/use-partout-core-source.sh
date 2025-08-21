#!/bin/bash
partout="submodules/partout"
partout_core="vendors/core"

set -e

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

echo "Updated partout manifest"
