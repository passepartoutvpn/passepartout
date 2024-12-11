#!/bin/bash
platform=$1
bundle exec fastlane --env secret,$platform asc_metadata
