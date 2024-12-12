source "https://rubygems.org"

gem "fastlane", :github => "keeshux/fastlane", :ref => "57b2e988e862b14c557419210dc5bd7c9a1636cc"
gem "dotenv"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
