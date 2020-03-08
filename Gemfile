source 'https://rubygems.org/'

gem 'discordrb'
gem 'listen'

# platform specific stuff for guard/listen:
gem 'wdm', '>= 0.1.0' if Gem.win_platform?

require 'rbconfig'
gem 'rb-kqueue', '>= 0.2'if RbConfig::CONFIG['target_os'] =~ /bsd|dragonfly/i
