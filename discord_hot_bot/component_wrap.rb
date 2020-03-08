module DiscordHotBot

  # An helper class that wraps a component used within the HotLoader class.
  # It allows to retrieve the path from a component and vice-versa plus a few extra features.

  class ComponentWrap

    # Create a ComponentWrap from a path.
    # The file must already be loaded and the path must be a valid component path.
    # Returns nil in case of error.
    def self.from_path(hot_loader, path)
      suffix = hot_loader.suffix
      return unless path.end_with?(suffix)
      begin
        comp_name = self.guess_component_name(path, suffix)
        comp = Object.const_get(comp_name)
        self.new hot_loader, comp, path
      rescue NameError
      end
    end

    # Guess the component name from a path.
    # Example:
    #     ~/bot/components/my_super_component.cmp.rb -> MySuperComponent
    def self.guess_component_name(path, suffix)
      File.basename(path)[0...-suffix.size]                  # basename & remove suffix
                         .split('_').map(&:capitalize).join  # snake_case -> PascalCase
    end

    attr_reader :path

    def initialize(hot_loader, comp, path)
      @hot_loader = hot_loader
      @component = comp
      @path = path
    end

    # Unload the component. It removes the component from the bot
    # then it cleans its internal: event handlers, commands, buckets and dependencies.
    def unload!
      event_handlers = @component.instance_variable_get('@event_handlers') || {}
      commands = @component.instance_variable_get('@commands') || {}
      buckets = @component.instance_variable_get('@buckets') || {}

      # Removing itself from the bot:
      bot = @hot_loader.bot
      event_handlers.values.flatten.each { |handler| bot.remove_handler(handler) }
      commands.keys.each { |name| bot.remove_command(name) }
      buckets.keys.each { |key| bot.instance_variable_get('@buckets')&.delete(key) }

      # Cleaning the ruby module:
      @component.remove_instance_variable('@event_handlers') rescue nil
      @component.remove_instance_variable('@commands') rescue nil
      @component.remove_instance_variable('@buckets') rescue nil
      @component.remove_instance_variable('@dependencies') rescue nil
    end

    def raw_component
      @component
    end

    # Check wether or not the current component depends on tested_path.
    def depend_on?(tested_path)
      dependencies = @component.instance_variable_get('@dependencies') || []
      absolute_dependencies = dependencies.map { |dep| File.join(File.dirname(@path), dep) }
      File.fnmatch(@path, tested_path) || !!absolute_dependencies.find { |abs_dep| File.fnmatch(abs_dep, tested_path, File::FNM_PATHNAME) }
    end

    def == other
      other.hot_loader == @hot_loader && other.raw_component == raw_component && other.path == @path
    end

    protected
    attr_reader :hot_loader
  end

end
