#!/bin/bash
bundle exec fastlane --env $1 get_version_number_unix 2>/dev/null | grep "Version: " | sed -E "s/^.*Version: (.*)$/\1/g"
