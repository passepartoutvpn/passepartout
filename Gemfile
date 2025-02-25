source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "f1ffaabe9d986eeedd20745213ca36c0b4c523a9"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
