source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "2f464bc16fbebf4dbac52ed7362993434af3f022"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
