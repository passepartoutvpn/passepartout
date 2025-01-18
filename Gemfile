source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "77198d601b9237c223dfe5550ce1c20f43140c79"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
