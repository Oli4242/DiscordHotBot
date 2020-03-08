require 'io/console'
require_relative 'discord_hot_bot/bot'
require_relative 'discord_hot_bot/config'
require_relative 'discord_hot_bot/component'

bot = DiscordHotBot::Bot.new(config_path: File.join(__dir__, 'config.yml'))

bot.run true

puts 'Running Press q or ^C to quit.'
until ['q', "\x03"].include? STDIN.getch; end
puts 'Quitting...'

bot.stop true
