source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "d81eebb7359fffc6ad2c26366919fc619ca76843"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
