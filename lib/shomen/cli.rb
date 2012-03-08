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

    #
    attr_accessor :source

    #
    attr_accessor :webcvs

    #
    attr_accessor :readme

    #
    attr_accessor :store

    #
    attr_accessor :markup

    #
    attr_accessor :scripts

    #
    attr_accessor :documents

    #
    attr_accessor :use_cache

    #
    def use_cache?
      @use_cache
    end

  private

    #
    def initialize(*argv)
      @engine     = (Dir['.yardoc'].first ? :yard : :rdoc)
      @format     = DEFAULT_FORMAT
      @readme     = Dir['README*'].first
      @source     = false
      @use_cache  = false
      @store      = nil
      @markup     = nil
      @scripts    = []
      @documents  = []

      parse(argv)

      @store ||= (engine == :yard ? '.yardoc' : '.rdoc')
    end

    #
    def run_rdoc
      preconfigure_rdoc unless use_cache?
      generate_from_rdoc     
    end

    #
    def run_yard
      preconfigure_yard unless use_cache?
      generate_from_yard
    end

    #
    def parse(argv)
      if i = argv.index('-')
        @documents = argv[i+1..-1]
        argv = argv[0...i]
      end

      parser = OptionParser.new

      options(parser)

      parser.parse!(argv)

      if !(force? or root?)
        $stderr.puts "ERROR: Not a project directory. Use --force to override."
        exit -1
      end

      @scripts = argv
    end

    #
    def options(parser)
      parser.on('-Y', '--yard', 'use YARD for parsing') do
        self.engine = :yard
      end
      parser.on('-R', '--rdoc', 'use RDoc for parsing') do
        self.engine = :rdoc
      end

      parser.on('-j', '--json', 'output JSON instead of YAML (default)') do
        self.format = :json
      end
      parser.on('-y', '--yaml', 'output YAML instead of JSON') do
        self.format = :yaml
      end

      parser.on('-d', '--db DIR', 'documentation store directory (deafult is `.rdoc` or `.yardoc`)') do |dir|
        @store = dir
      end
      parser.on('-c', '--use-cache', 'do not regenerate docs, use pre-existing cache') do
        @use_cache = true
      end

      parser.on('-s', '--source', 'include full source in script documentation') do
        #Shomen.source = true
        @source = true
      end
      parser.on('-w', '--webcvs URI', 'prefix link to source code') do |uri|
        #Shomen.webcvs = uri
        @webcvs = uri
      end
      parser.on('-r', '--readme FILE', 'which file to use as main') do |file|
        @readme = file
      end

      #parser.on('--save', 'save options for future use') do |markup|
      #  @save = true
      #end

      parser.on('--markup TYPE', 'markup type used for comments (rdoc, md, tomdoc)') do |markup|
        @markup = markup.to_sym
      end

      parser.on('-F', '--force') do
        $FORCE = true
      end

      parser.on_tail('--debug', 'run with $DEBUG set to true') do
        $DEBUG = true
      end
      parser.on_tail('--warn', 'run with $VERBOSE set to true') do
        $VERBOSE = true
      end

      parser.on_tail('--help', 'see this help message') do
        puts parser; exit -1
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

      options = {}
      options[:files] = documents
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

      options = {}
      options[:files] = documents # + scripts
      options[:store] = store

      rdoc = Shomen::RDocAdaptor.new(options)
      rdoc.generate

      return rdoc.table
    end

    #
    def preconfigure_yard(*argv)
      require_yard

      argv = []
      argv.concat ["-q"]
      argv.concat ["-n"]
      argv.concat ["-b", store]
      argv.concat ["--markup", markup] if markup
      argv.concat ["--debug"] if $DEBUG
      #argv.concat ["--no-save"] #unless save
      argv.concat scripts
      #argv.concat documents unless documents.empty?

      # clear the registry in memory to remove any previous runs
      YARD::Registry.clear

      yard = YARD::CLI::Yardoc.new
      $stderr.puts('yard ' + argv.join(' ')) if $DEBUG
      yard.run(*argv)
    end

    #
    def preconfigure_rdoc
      require_rdoc

      argv = []
      argv.concat ["-q"]
      argv.concat ["-r"]
      argv.concat ["-o", store]
      argv.concat ["--markup", markup] if markup
      argv.concat ["-D"] if $DEBUG
      #argv.concat ["--write-options"] #if save
      argv.concat scripts
      #argv.concat ['-', *documents] unless documents.empty?

      rdoc = ::RDoc::RDoc.new
      $stderr.puts('rdoc ' + argv.join(' ')) if $DEBUG
      rdoc.document(argv)
    end

    #
    def require_yard
      require 'yard'
    end

    def require_rdoc
      gem 'rdoc', '>3'
      require 'rdoc'
    end

=begin
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
=end

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
