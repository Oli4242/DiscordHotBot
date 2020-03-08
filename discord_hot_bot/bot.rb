require 'discordrb'
require_relative 'hot_loader'

module DiscordHotBot

  # The main class. It extends Discordrb::Commands::CommandBot and gives it hot reloading abilities.
  #
  # The whole project in a nutshell:
  # At initialization the hot loader finds and loads all the components.
  # At runtime the hot loader monitors the components directory and triggers a ReloadRequest
  # when a file needs to be reloaded. The bot handles this event and reloads the file(s).

  class Bot < Discordrb::Commands::CommandBot
    def initialize(config_path:, **attributes)
      config = Config.new(config_path)

      super token: config.token, prefix: config.prefix, **attributes

      @raise_event_mutex = Mutex.new            # mutex to make raise_event thread-safe
      @hot_loader = HotLoader.new(self, config)
      @hot_loader.cold_load!                    # cold loads the components at init

      add_handler ReloadRequestHandler.new(nil, proc { |reload_request|
        reload_request.files.each { |file| @hot_loader.reload! file }
      })
    end

    # A thread-safe version of discordrb's raise_event to avoid any kind of race condition.
    # (might be unnecessary due to Ruby's GIL but I prefer to play it safe...)
    def raise_event(event)
      @raise_event_mutex.synchronize { super(event) }
    end

    def run(async = false)
      @hot_loader.listen
      super(async)
    end

    def stop(no_sync = false)
      @hot_loader.stop
      super(no_sync)
    end
  end

end
