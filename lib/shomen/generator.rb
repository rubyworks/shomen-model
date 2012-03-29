module Shomen

  begin; gem 'json'; rescue; end

  require 'yaml'
  require 'json'

  # Generates Shomen document for any given library.
  #
  class Generator

    #
    # Default output format is JSON.
    #
    DEFAULT_FORMAT = 'json'

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
    # Initialize new generator.
    #
    # options - Generator options. [Hash]
    #
    # Returns Generator instance.
    #
    def initialize(options)
      @engine     = (Dir['.yardoc'].first ? :yard : :rdoc)
      @format     = DEFAULT_FORMAT
      @readme     = Dir['README*'].first
      @source     = false
      @use_cache  = false
      @store      = nil
      @markup     = nil
      @scripts    = []
      @documents  = []

      options.each do |k,v|
        __send__("#{k}=", v)
      end

      @store ||= (engine == :yard ? '.yardoc' : '.rdoc')
    end

    #
    def produce_format
      case format.to_sym
      when :yaml
        produce_yaml
      else
        produce_json
      end
    end

    #
    alias to_s product_format

    #
    def produce_yaml
      produce_table.to_yaml
    end

    #
    def produce_json
      force_encoding(produce_table).to_json
    end

    #
    def produce_table
      case engine.to_sym
      when :yard
        run_yard
      else
        run_rdoc
      end
    end

    #
    # Generate with RDoc as backend processor.
    #
    def run_rdoc
      preconfigure_rdoc unless use_cache?
      generate_from_rdoc     
    end

    #
    # Generate with YARD as backend processor.
    #
    def run_yard
      preconfigure_yard unless use_cache?
      generate_from_yard
    end


    #
    # Is this a project directory?
    #
    # Returns true or false.
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
    # Generate documentatin use YARD.
    #
    # Returns documentation table. [Hash]
    #
    def generate_from_yard
      require 'shomen/yard'

      options = {}
      options[:files]  = documents
      options[:store]  = store
      options[:webcvs] = webcvs
      options[:source] = source

      yard = Shomen::YardAdaptor.new(options)
      yard.generate

      return yard.table
    end

    # TODO: what about reading options from .document ?
    #       also rdoc.options[:document] ?

    #
    # Generate documentation from RDoc.
    #
    # Returns documentation table. [Hash]
    #
    def generate_from_rdoc
      require 'shomen/rdoc'

      options = {}
      options[:files]  = documents # + scripts
      options[:store]  = store
      options[:webcvs] = webcvs
      options[:source] = source

      rdoc = Shomen::RDocAdaptor.new(options)
      rdoc.generate

      return rdoc.table
    end

    #
    # Preconfigure YARD.
    #
    def preconfigure_yard
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
    # Preconfigure RDoc.
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
    # Require YARD library.
    #
    def require_yard
      require 'yard'
    end

    #
    # Require RDoc library.
    #
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
    # Force encoding.
    #
    def force_encoding(value)
      case value
      when Time,Date
        value = value.dup if value.frozen?
        value.to_s.force_encoding('UTF-8')
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
