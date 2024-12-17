#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

rm -rf $api_path
git clone $api_git --depth 1 $api_path

rm -rf $api_package_path
mkdir -p $api_package_path
mv $api_path/$api_version $api_package_path
rm -rf $api_path
