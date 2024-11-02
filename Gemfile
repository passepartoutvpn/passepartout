source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "91a3bc8cbf26dd761920939fd7579ee4362ce9b3"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
