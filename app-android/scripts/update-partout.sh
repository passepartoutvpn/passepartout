#!/bin/bash
partout_path="../submodules/partout"
openssl_path="../../openssl-swift/openssl.artifactbundle/lib/android/arm64"
cpp_path="app/src/main/cpp"
headers_path="$cpp_path"
libs_path="$cpp_path/libs/arm64-v8a"

set -e
pushd $partout_path
partout_sha1=`git rev-parse --short HEAD`
scripts/build-android.sh release
popd

rm -f $headers_path/partout.h
rm -f $libs_path/libPartout*
rm -rf $libs_path/openssl

# Partout
cp $partout_path/Sources/ABI/Library_C/include/partout.h $headers_path
cp $partout_path/.build/release/libPartout.a $libs_path/libPartout-$partout_sha1.a
cp $partout_path/.build/release/libPartoutImplementations.a $libs_path/libPartoutImplementations-$partout_sha1.a

# OpenSSL
ossl_version=3.5.2
mkdir $libs_path/openssl
cp $openssl_path/libcrypto.a $libs_path/openssl/libcrypto-$ossl_version.a
cp $openssl_path/libssl.a $libs_path/openssl/libssl-$ossl_version.a
