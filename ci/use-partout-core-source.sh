#!/bin/bash
manifest="submodules/partout/Package.swift"
core_status=`git submodule status submodules/partout-core`
sha1=${core_status:1:40}

env_line_old="environment = .remoteBinary"
env_line_new="environment = .remoteSource"
sed -i '' "s/^${env_line_old}$/${env_line_new}/" "$manifest"
if ! grep -q "^${env_line_new}$" "$manifest"; then
    echo "Unable to set environment"
    exit 1
fi

sha1_line_pattern="let sha1 = .*"
sha1_line_new="let sha1 = \"${sha1}\""
sed -i '' "s/^${sha1_line_pattern}$/${sha1_line_new}/" "$manifest"
if ! grep -q "^${sha1_line_new}$" "$manifest"; then
    echo "Unable to set SHA-1"
    exit 1
fi

echo "Updated partout manifest, partout-core -> $sha1"
