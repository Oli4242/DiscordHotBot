require 'yaml'

module DiscordHotBot

  # The class responsible for reading and parsing the YAML configuration.

  class Config
    attr_reader :token, :prefix, :components_dir, :components_suffix

    def initialize(config_path)
      fatal_error "Config path (`#{config_path}`) must be absolute" unless File.absolute_path?(config_path)
      fatal_error "Config path (`#{config_path}`) must be a file" unless File.file?(config_path)

      base_path = File.dirname(config_path)
      config = YAML.load(File.read(config_path))

                                                                # The Discordrb token can be passed:
      command_line = ARGV[0]                                    # 1. as a command line argument
      token_file = config.dig('discordrb', 'token', 'file')     # 2. within a file
      token_variable = config.dig('discordrb', 'token', 'env')  # 3. as an environment variable
                                                                # (in that order of priority)
      @token = command_line
      @token ||= File.open(File.realpath(token_file, base_path), &:readline).chomp
      @token ||= ENV[token_variable]
      fatal_error 'Unspecified discordrb token' if @token.nil?

      @prefix = config.dig('discordrb', 'prefix')
      fatal_error 'Unspecified discordrb prefix' if @prefix.nil?

      @components_dir = File.realpath(config.dig('components', 'directory'), base_path)  # the path is interpreted relatively to the config file
      fatal_error 'Unspecified components directory' if @components_dir.nil?

      @components_suffix = config.dig('components', 'suffix')
      fatal_error 'Unspecified components suffix' if @components_suffix.nil?
    end

    private
    # Any error in the config is considered fatal and exits the program
    def fatal_error(message)
      STDERR.puts "Configuration error: #{message}"
      exit
    end
  end
end
