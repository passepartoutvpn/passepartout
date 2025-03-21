source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "e881500859cd6df477866288cff64ef3ec6e027d"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
