#!/bin/sh
TARGET="dev" bundle exec fastlane --env secret-deploy,dev-deploy dev_deploy
VERSION=`agvtool mvers -terse1`
BUILD=`agvtool vers -terse`
git tag "v$VERSION-a$BUILD"
