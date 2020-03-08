require 'listen'
require_relative 'component_wrap'
require_relative 'reload_request'

module DiscordHotBot

  # The HotLoader class provides methods to load / unload / reload components
  # and to monitor the components directory.

  class HotLoader
    LOGGER = Logger.new(STDOUT, progname: 'HotLoader', formatter: proc { |severity, datetime, progname, msg|
      "(#{severity} : #{progname} @ #{datetime.strftime(Discordrb::LOG_TIMESTAMP_FORMAT)}) #{msg}\n"
    })

    attr_reader :suffix, :bot

    def initialize(bot, config)
      @bot = bot
      @directory = config.components_dir
      @suffix = config.components_suffix
      @loaded_components = []            # list of loaded components as a list of ComponentWrap
      error "Components directory not found: #{@directory}" unless File.directory?(@directory)
    end

    # Find and load all components.
    # Used to initialize the bot before any hot reloading happens.
    def cold_load!
      components_pattern = File.join(@directory, '**', '*' + @suffix)
      info "Cold loading: #{components_pattern}"
      Dir.glob(components_pattern).each { |file| reload! file }
    end

    # Try to load `path` as a component and include it into the bot
    def load!(path)
      comp_name = ComponentWrap.guess_component_name(path, @suffix)
      info "Loading: #{comp_name} from #{path}"

      load path
      component_wrap = ComponentWrap.from_path(self, path)

      if component_wrap
        @loaded_components.push component_wrap
        @bot.include! component_wrap.raw_component
      elsif path.end_with? @suffix
        error "Can't load: #{path}: it does not define `module #{comp_name}`"
      else
        error "Can't load: #{path}: it is not a component file (*#{@suffix})"
      end
    end

    # Try to unload `path` as a component and exclude it from the bot.
    def unload!(path)
      component_wrap = ComponentWrap.from_path(self, path)
      if component_wrap
        info "Unloading: #{component_wrap.raw_component.name} from #{path}"
        component_wrap.unload!
        @loaded_components.delete(component_wrap)
      end
    end

    # Reload `path` as a component and update the bot.
    # Or just load the component if it hasn't been loaded already.
    def reload!(path)
      unload! path
      load! path if File.file?(path)  # condition to avoid errors when a file is removed or renamed...
    end

    # Monitors the components directory:
    # when a change occurs it finds the dependent component(s)
    # then it makes a ReloadRequest so the right file gets reloaded.
    def listen
      @listener ||= Listen.to(@directory) do |modified, added, removed|
        to_reload = []                                                               # list of component path to reload

        (added + modified + removed).each do |file|
          to_reload.push(file) if file.end_with? @suffix                             # add the file to the reload list if it's a component

          dependent_comps = @loaded_components.select{ |comp| comp.depend_on? file } # find every components that depend on the current file
          to_reload += dependent_comps.map(&:path) if dependent_comps                # add their path to the reload list
        end

        @bot.raise_event ReloadRequest.new(to_reload.uniq) unless to_reload.empty?
      end

      @listener.start unless @listener.processing?
    end

    def stop
      @listener&.stop if @listener&.processing?
    end

    private
    def info(message)
      LOGGER.info message
    end
    def warn(message)
      LOGGER.warn message
    end
    def error(message)
      LOGGER.error message
    end
  end

end
