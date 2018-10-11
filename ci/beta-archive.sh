#!/bin/sh
TARGET="beta" bundle exec fastlane --env secret-codesign,beta-archive create_archive
