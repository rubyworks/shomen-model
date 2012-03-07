module Shomen

  begin; gem 'json'; rescue; end

  require 'optparse'
  require 'yaml'
  require 'json'

  #
  def self.cli(*argv)
    CLI.run(*argv)
  end

  # TODO: Instead of using command line options for shomen should
  # we use environment variables ?

  # The command line interface for generating Shomen documentation.
  #
  # Shomen options must come first, followed by an `rdoc` or `yard`
  # command depending on which system you wish to use for parsing.
  # The `rdoc` or `yard` commands are passed to the command shell
  # as given so they support all same options as the normal command
  # invocation, less any options shomen must remove or change for the
  # sake fo generating Shomen documentation.
  #
  # NOTE: Currently Shomen doesn't filter the `rdoc` or `yard` command
  # calls as mush as it should, so some options can cause the
  # documentation to be malformed, or not be produced at all, so 
  # please use the options judiciously.
  #
  # @example
  #   shomen -s rdoc -m README [A-Z]*.* lib
  #   shomen yard --readme README.md lib [A-Z]*.*
  #
  class CLI

    #
    DEFAULT_FORMAT = 'json'

    # Command line options accepted by shomen command.
    SHOMEN_OPTIONS = %w{debug warn help force source store format engine}

    #
    def self.run(*argv)
      new(*argv).run
    end

    #
    def run
      table  = case engine.to_sym
               when :yard
                 run_yard
               else
                 run_rdoc
               end

      output = case format.to_sym
               when :yaml
                 table.to_yaml
               else
                 force_encoding(table).to_json
               end

      $stdout.puts output
    end

    #
    def force?; $FORCE; end

    #
    attr_accessor :engine

    #
    attr_accessor :format

  private

    #
    def initialize(*argv)
      @format   = DEFAULT_FORMAT
      @store    = nil
      @files    = []
      @engine   = (Dir['.yardoc'].first ? :yard : :rdoc)
      @pre_argv = nil

      parse(argv, *SHOMEN_OPTIONS)
    end

    #
    def run_rdoc
      preconfigure_rdoc
      generate_from_rdoc     
    end

    #
    def run_yard
      preconfigure_yard
      generate_from_yard
    end

    #
    def parse(argv, *choices)
      if i = argv.index('-')
        @pre_argv = argv[i+1..-1]
        argv = argv[0...i]
      end

      parser = OptionParser.new

      choices.each do |choice|
        send("option_#{choice}", parser)
      end

      parser.parse!(argv)

      if !(force? or root?)
        $stderr.puts "ERROR: Not a project directory. Use --force to override."
        exit -1
      end

      @files = argv
    end

    #
    def option_engine(parser)
      parser.on('-Y', '--yard', 'use YARD for parsing') do
        self.engine = :yard
      end
      parser.on('-R', '--rdoc', 'use RDoc for parsing') do
        self.engine = :rdoc
      end
    end

    #
    def option_format(parser)
      parser.on('-y', '--yaml', 'output YAML instead of JSON') do
        self.format = 'yaml'
      end
      parser.on('-j', '--json', 'output JSON instead of YAML (default)') do
        self.format = 'json'
      end
      #parser.on('-f', '--format NAME') do |format|
      #  if not %w{json yaml}.include?(format)
      #    $stderr.puts "ERROR: Format must be 'yaml` or 'json`."
      #    exit -1
      #  end
      #  self.format = format
      #end
    end

    #
    def option_store(parser)
      parser.on('-d', '--db DIR', 'documentation store directory') do |dir|
        @store = dir
      end
    end

    #
    def option_source(parser)
      parser.on('-s', '--source', 'include full source in script documentation') do
        Shomen.source = true
      end
      parser.on('-w', '--webcvs URI', 'prefix link to source code') do |uri|
        Shomen.webcvs = uri
      end
    end

    #
    def option_force(parser)
      parser.on('-F', '--force') do
        $FORCE = true
      end
    end

    #
    def option_debug(parser)
      parser.on_tail('--debug', 'run with $DEBUG set to true') do
        $DEBUG = true
      end
    end

    #
    def option_warn(parser)
      parser.on_tail('-w', '--warn', 'run with $VERBOSE set to true') do
        $VERBOSE = true
      end
    end

    #
    def option_help(parser)
      parser.on_tail('--help') do
        puts parser
        exit 0
      end
    end

    #
    # Is this a project directory?
    #
    def root?
      root = false
      root = true if File.exist?('.ruby')
      root = true if File.exist?('.yardoc')
      root = true if File.exist?('.rdoc')
      root = true if File.exist?('.git')
      root = true if File.exist?('.hg')
      root = true if File.exist?('_darcs')
      root
    end

    # TODO: what about reading options from .yardopts ?
    #       also yard.options[:yardopts] ?

    #
    def generate_from_yard
      require 'shomen/yard'

      files = @files || []
      store = @store || '.yardoc'

      options = {}
      options[:files] = files
      options[:store] = store

      yard = Shomen::YardAdaptor.new(options)
      yard.generate

      return yard.table
    end

    # TODO: what about reading options from .document ?
    #       also rdoc.options[:document] ?

    #
    def generate_from_rdoc
      require 'shomen/rdoc'

      files = @files || []
      store = @store || '.rdoc'

      options = {}
      options[:files] = files
      options[:store] = store

      rdoc = Shomen::RDocAdaptor.new(options)
      rdoc.generate

      return rdoc.table
    end

    #
    def preconfigure_yard(*argv)
      return unless @pre_argv

      argv = @pre_argv

      argv.unshift('-n')  # do not generate yard documentation
      argv.unshift('-q')  # supress usual output

      # clear the registry in memory to remove any previous runs
      YARD::Registry.clear

      yard = YARD::CLI::Yardoc.new
      yard.run(*argv)

      @files = yard.options[:files].map(&:filename) + yard.files
      @store = yard.options[:db]
    end

    #
    def preconfigure_rdoc
      return unless @pre_argv

      argv = @pre_argv

      argv.unshift('-q')  # supress usual output

      rdoc = ::RDoc::RDoc.new
      rdoc.document(argv)

      # TODO: can we get files and store from rdoc's parsed options?
    end

    #
    # Remove setting options from command line arguments.
    #
    def remove_options(argv, *options)
      options.each do |opt|
        i = argv.index(opt)
        if i
          argv.delete_at(i)
          argv.delete_at(i)
        end
      end
      argv
    end

    #
    # Remove flag options from command line arguments.
    #
    def remove_flags(argv, *flags)
      flags.each do |opt|
        i = argv.index(opt)
        if i
          argv.delete_index(i)
        end
      end
      argv
    end

    #
    def force_encoding(value)
      case value
      when String
        value = value.dup if value.frozen?
        value.force_encoding('UTF-8')
      when Array
        value.map{ |v| force_encoding(v) }
      when Hash
        new = {}
        value.each do |k,v|
          k = force_encoding(k)
          v = force_encoding(v)
          new[k] = v
        end
        new
      end
    end

  end

end


=begin
  def self.cli(*argv)
    idx = argv.index('rdoc') || argv.index('yard')

    abort "ERROR: must specifiy `rdoc` or `yard`." unless idx

    cmd = argv[idx]
    case cmd
    when 'rdoc'
      shomen_options = argv[0...idx]
      parser_command = argv[idx..-1]
      CLI::RDocCommand.cli(*shomen_options).run(*parser_command)
    when 'yard'
      shomen_options = argv[0...idx]
      parser_command = argv[idx..-1]
      CLI::YARDCommand.cli(*shomen_options).run(*parser_command)
    end
  end
=end
