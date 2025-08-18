#!/bin/bash
partout_path="../submodules/partout"
cpp_path="app/src/main/cpp"
headers_path="$cpp_path"

set -e
pushd $partout_path
partout_sha1=`git rev-parse --short HEAD`
scripts/build-android.sh 1  # 1 for Release
popd

rm -f $headers_path/partout.h
rm -rf $cpp_path/libs/partout-*

libs_path="$cpp_path/libs/partout-${partout_sha1}/arm64-v8a"
mkdir -p $libs_path
cp $partout_path/Sources/ABI/Library_C/include/partout.h $headers_path
cp $partout_path/.build/release/libPartout.so $libs_path/libPartout.so
cp $partout_path/.build/release/libPartoutImplementations.so $libs_path/libPartoutImplementations.so
