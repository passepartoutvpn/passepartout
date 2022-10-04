#!/bin/bash
PLATFORM=$1
bundle exec fastlane --env $PLATFORM,secret deliver_screenshots
