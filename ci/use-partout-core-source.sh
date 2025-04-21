#!/bin/bash
manifest="Submodules/partout/Package.swift"
core_status=`git submodule status Submodules/partout-core`
sha1=${core_status:1:40}
echo "Update partout manifest, partout-core -> $sha1"

sha1_line="let sha1 = .*"
env_line="environment = .remoteBinary"
sed -i '' "s/^${sha1_line}$/let sha1 = \"${sha1}\"/" "$manifest"
sed -i '' "s/^${env_line}$/environment = .remoteSource/" "$manifest"
