module Shomen

  begin; gem 'json'; rescue; end

  require 'yaml'
  require 'json'

  #require 'shomen-model/metadata'
  #require 'shomen-model'

  # Shared base class that can be used by generators.
  #
  class Generator

    # Default output format is JSON.
    DEFAULT_FORMAT = 'json'

    # Is `$FORCE` set?
    #
    # Return true/false.
    def force?
      $FORCE
    end

    # Outpu format is eitehr :yaml or :json. The default is :json.
    attr_accessor :format

    # Flag to include full source code in script entries.
    #
    # Returns true/false.
    attr_accessor :source

    # URI prefix to link to online documentation.
    #
    # Returns String.
    attr_accessor :webcvs

    # Name of README file.
    attr_accessor :readme

    # Markup used for comments. This is typically either :rdoc or :markdown.
    attr_accessor :markup

    # List of scripts to document.
    attr_accessor :scripts

    # List of "information documents" to document.
    attr_accessor :documents

    # Include source code in scripts?
    #
    # Returns true/false.
    def source?
      @soruce
    end

  private

    # Initialize new generator.
    #
    # options - Hash of generator options.
    #
    # Returns Generator instance.
    def initialize(options)
      @format     = DEFAULT_FORMAT
      @readme     = Dir['README*'].first
      @source     = false
      @use_cache  = false
      @markup     = nil
      @scripts    = []
      @documents  = []

      options.each do |k,v|
        __send__("#{k}=", v)
      end
    end

  public

    # Produce documentation in YAML or JSON format depending
    # on the setting of #format setting.
    #
    # Returns String of either YAML or JSON.
    def produce_format
      case format.to_sym
      when :yaml
        produce_yaml
      else
        produce_json
      end
    end

    # Alias for #produce_format.
    #
    # Returns String of either YAML or JSON.
    alias to_s produce_format

    # Documentation table in YAML format.
    #
    # Returns String of YAML.
    def produce_yaml
      produce_table.to_yaml
    end

    # Documentation table in JSON format.
    #
    # Returns String of JSON.
    def produce_json
      force_encoding(produce_table).to_json
    end

    # Generates documentation table using rdoc or yard 
    # depending on the `adapter` setting.
    #
    # Returns documentation table. [Hash]
    def produce_table
      generate
    end

    # Project metadata.
    #
    # Returns Metadata instance.
    def project_metadata
      @project_metadata ||= Shomen::Metadata.new
    end

  private


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

    # Force encoding to UTF-8.
    #
    # value - Common core object.
    #
    # Returns object with values encoded to UTF-8.
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
