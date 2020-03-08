require 'discordrb'

module DiscordHotBot

  # Event fired when one or more file(s) need(s) to be reloaded.
  # Fired by the HotLoader class. Handled by the Bot class.

  class ReloadRequest < Discordrb::Events::Event
    attr_reader :files

    def initialize(files)
      @files = files
    end
  end

  # The handler class for ReloadRequest.

  class ReloadRequestHandler < Discordrb::Events::EventHandler
    def matches?(event)
      event.is_a? ReloadRequest
    end
  end

end
