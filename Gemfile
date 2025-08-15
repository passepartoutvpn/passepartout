source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "6f26127e60b953d58e4a6a3064613fd784d0af61"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
