source "https://rubygems.org"

gem "fastlane", ">= 2.2.0", :github => "keeshux/fastlane", :branch => "bugfix/build-multiplatform-for-ipa-pkg"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
