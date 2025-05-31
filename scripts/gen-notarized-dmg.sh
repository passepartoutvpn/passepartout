#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
source $cwd/env.secrets.sh
cd $cwd/..

set -e
platform="macOS"
arch="arm64"
developer_id="1"
ci/xcode-archive.sh $platform $developer_id $arch
ci/xcode-export.sh $platform $developer_id
ci/dmg-generate.sh $arch
ci/dmg-notarize.sh $arch $apple_id $apple_password
ci/dmg-sign.sh $arch $gpg_fingerprint $gpg_passphrase
