#!/bin/sh
TARGET="dev" bundle exec fastlane --env secret-codesign,dev-archive create_archive
