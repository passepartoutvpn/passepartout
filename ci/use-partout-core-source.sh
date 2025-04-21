#!/bin/bash
manifest="Submodules/partout/Package.swift"
sha1=`git submodule status Submodules/partout-core | cut -d ' ' -f 2`
sha1_line="let sha1 = .*"
env_line="environment = .remoteBinary"
sed -i '' "s/^${sha1_line}$/let sha1 = \"${sha1}\"/" "$manifest"
sed -i '' "s/^${env_line}$/environment = .remoteSource/" "$manifest"
