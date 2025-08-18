#!/bin/bash
partout_path="../submodules/partout"
cpp_path="app/src/main/cpp"
headers_path="$cpp_path"
libs_path="$cpp_path/libs/arm64-v8a"

set -e
pushd $partout_path
partout_sha1=`git rev-parse --short HEAD`
scripts/build-android.sh 1  # 1 for Release
popd

rm -f $headers_path/partout.h
rm -f $libs_path/libPartout*

cp $partout_path/Sources/ABI/Library_C/include/partout.h $headers_path
cp $partout_path/.build/release/libPartout.so $libs_path/libPartout-$partout_sha1.so
cp $partout_path/.build/release/libPartoutImplementations.so $libs_path/libPartoutImplementations-$partout_sha1.so
