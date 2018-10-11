#!/bin/sh
TARGET="beta" bundle exec fastlane --env secret-deploy,beta-deploy beta_deploy
VERSION=`agvtool mvers -terse1`
BUILD=`agvtool vers -terse`
git tag "v$VERSION-b$BUILD"
