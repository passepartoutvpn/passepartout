#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
source $cwd/env.secrets.sh
cd $cwd/..

set -e
platform="macOS"
arch="arm64"
ci/xcode-archive.sh $platform 1 $arch
ci/xcode-export.sh $platform 1
ci/dmg-generate.sh $arch
ci/dmg-sign.sh $arch $gpg_fingerprint $gpg_passphrase
ci/dmg-notarize.sh $arch $apple_id $apple_password
