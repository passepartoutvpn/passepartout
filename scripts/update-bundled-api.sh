#!/bin/bash
cwd=`dirname $0`
api_version="v5"
api_path="$cwd/../.api"
package_path="$cwd/../Library/Sources/CommonAPI/API"

rm -rf $api_path
git clone https://github.com/passepartoutvpn/api --depth 1 $api_path

rm -rf $package_path
mkdir -p $package_path
mv $api_path/$api_version $package_path
rm -rf $api_path
