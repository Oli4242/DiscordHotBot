require 'discordrb'
require_relative 'hot_loader'

module DiscordHotBot

  # The main class. It extends Discordrb::Commands::CommandBot and gives it hot reloading abilities.
  #
  # The whole project in a nutshell:
  # At initialization the hot loader finds and loads all the components.
  # At runtime the hot loader monitors the components directory.
  # When a file needs to be reloaded the hot loader prevents the bot from handling new events
  # and waits for the current events threads to be terminated then it safely reloads the file(s).

  class Bot < Discordrb::Commands::CommandBot
    def initialize(config_path:, **attributes)
      config = Config.new(config_path)

      super token: config.token, prefix: config.prefix, **attributes

      @hot_loader = HotLoader.new(self, config)
      @hot_loader.cold_load!                    # cold loads the components at init
    end

    # A thread-safe version of discordrb's raise_event.
    # It can be paused when a component is needs to be reloaded.
    def raise_event(event)
      sleep 0.1 while @hot_loader.mutex.locked?
      super(event)
    end

    def run(async = false)
      @hot_loader.listen
      super(async)
    end

    def stop
      @hot_loader.stop
      super
    end
  end

end
