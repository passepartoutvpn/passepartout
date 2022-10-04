#!/bin/bash
bundle exec fastlane --env $1 get_build_number_unix 2>/dev/null | grep "Build: " | sed -E "s/^.*Build: (.*)$/\1/g"
