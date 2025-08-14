#!/bin/bash
partout_path="../submodules/partout"
cpp_path="app/src/main/cpp"
headers_path="$cpp_path"
libs_path="$cpp_path/libs/arm64-v8a"
set -e
pushd $partout_path
sha1=`git rev-parse --short HEAD`
scripts/build-android.sh release
popd
cp $partout_path/Sources/ABI/Library_C/include/partout.h $headers_path
cp $partout_path/.build/release/libPartout.a $libs_path/libPartout-$sha1.a
cp $partout_path/.build/release/libPartoutImplementations.a $libs_path/libPartoutImplementations-$sha1.a
