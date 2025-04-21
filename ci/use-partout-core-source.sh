#!/bin/bash
env_line="environment = .remoteBinary"
sed -i '' "s/^${env_line}$/environment = .remoteSource/" "Submodules/partout/Package.swift"
