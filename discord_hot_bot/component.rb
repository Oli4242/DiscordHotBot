module DiscordHotBot

  # The module that helps to create hot-reloadable bot components.
  # It provides basic functionnalities to manage state and dependencies.

  module Component
    # Automagically extend the caller with Discordrb's base containers
    def self.extended(extender)
      extender.extend Discordrb::EventContainer
      extender.extend Discordrb::Commands::CommandContainer
    end

    # Set which path this component depends on. (Accepts globs)
    def depend_on(*globs)
      @dependencies = globs
    end

    # An easy way to keep the state of the component between reloads.
    def state
      @state ||= OpenStruct.new
    end

    alias_method :s, :state
  end

end
