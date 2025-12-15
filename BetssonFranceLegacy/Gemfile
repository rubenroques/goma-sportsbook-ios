source "https://rubygems.org"

Deprecate.skip = true if defined?(Deprecate.skip)
Gem::Deprecate.skip = true if defined?(Gem::Deprecate.skip)

gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
