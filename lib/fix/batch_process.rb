module Fix
  class BatchProcess
    attr_reader :ids, :log, :cli_ptions, :log_level

    def initialize(ids_file: nil, ids: [], log_level: Logger::INFO)
      # Try reading ids from :ids_file first if it's given
      @ids = File.readlines(ids_file, chomp: true) if ids_file
      # Set ids to given param if not from a file
      @ids ||= ids
      @cli_options = {}
      @log = Logger.new(STDOUT)
      @log.level = log_level
    end

    # asset_resources Returns an array of AssetResource instances for the given ids.
    # @return [Array<AssetResource>] An array of AssetResource instances.
    def asset_resources
      @asset_resources ||= ids.map do |id|
        log.info "Finding Asset Resource '#{id}'..."
        begin
          AssetResource.find(id)
        rescue => e
          log_error(e)
          nil
        end
      end.compact
    end

    def log_error(e)
      log.error "#{e.class}: #{e.message}"
      log.debug "Backtrace:\n#{e.backtrace.join("\t\t\n")}\n\n"
    end

    # run! is the main method to be implemented by subclasses.
    def run
      log.warn "No action taken. Put your logic in the #{self.class}#run! method"
    end

    # self.cli_options A hash to store command line options.
    def self.cli_options
      @cli_options ||= {}
    end

    # self.option_parser Creates a default OptionParser for cli options and allows subclasses
    # to add their own options.
    # @param block [Proc] A block that takes an OptionParser instance as an argument.
    # @return [OptionParser] The OptionParser instance.
    # Usage:
    #  class MyBatchProcess < BatchProcess
    #    def initialize(my_option:, **args)
    #      super(**args)
    #      @my_option = my_option
    #    end
    #
    #    option_parser do |opts|
    #      opts.on("-m", "--my-option", "My custom option") do |my_option_val|
    #        # Assign option values to the cli_options hash.
    #        cli_options[:my_option] = my_option_val
    #      end
    #    end
    #  end
    def self.option_parser(&block)
      # Set a default options for all BatchProcess classes
      @option_parser ||= OptionParser.new do |opts|
        # Allow verbose ouput
        opts.on('-l', '--log-level [0-5]', '0=DEBUG, 1=INFO, 2=WARN, 3=ERROR, 4=FATAL, 5=UNKNOWN') do |log_level|
          cli_options[:log_level] = log_level[/\d+/].to_i || 1
        end

        # Allow file input of AAPB IDs
        opts.on("-f", "--file FILE", "List of AAPB IDs, one per line") do |file|
          cli_options[:ids_file] = file
        end
      end

      # Call the passed block with option parser instance if a block was given.
      block.call(@option_parser) if block_given?

      # Return the option parser.
      @option_parser
    end

    # self.run_cli Parses command line options and runs the batch process.
    def self.run_cli
      # Call option_parser.parse! to set cli_options from $ARGV
      option_parser.parse!

      # Run the batch process with cli_options
      new(**cli_options).run
    end
  end
end