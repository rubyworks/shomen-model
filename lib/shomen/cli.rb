require 'optparse'
require 'yaml'
require 'json'

module Shomen

  # Command line interface. (YARD oriented for now).
  #
  def self.cli(*argv)
    options = {}
    options[:adapter] = :yard
    options[:format]  = :json
    options[:force]   = false
    options[:clear]   = false

    cli_options(options).parse!(argv)

    if options[:server]
      return require 'shomen/server'
    end

    if !options[:force] && !root?
      $stderr.puts "Not a project directory. Use --force to override."
      exit -1
    end

    if !options[:adapter]
      options[:adapter] = :yard if File.directory?('.yardoc')
    end

    case options[:adapter]
    when :yard, :y
      require 'shomen/yard'
      yard = Shomen::YardAdaptor.new(options)
      yard.generate
      if options[:format] == :yaml
        $stdout.puts yard.table.to_yaml
      else
        $stdout.puts yard.table.to_json
      end
    when :tomdoc, :t
      # TODO
    when :rdoc, :r
      # TODO
    when :ri
      # TODO
    else
      abort "unrecognized adapter -- #{options[:adapter]}"
    end

  end

  def self.cli_options(options)
    OptionParser.new do |opt|
      opt.on('-a', '--adapter NAME') do |arg|
        options[:adapter] = arg.to_sym
      end
      opt.on('-y', '--yaml', 'output YAML instead of JSON') do
        options[:format] = :yaml
      end
      opt.on('-c', '--clear') do
        options[:clear] = true
      end
      opt.on('-f', '--force') do
        options[:force] = true
      end
      opt.on('--yardopts FILE') do |file|
        options[:yardopts] = file
      end
      opt.on('--server') do
        options[:server] = true
      end
      opt.on_tail('-D', '--debug', 'run with $DEBUG set to true') do
        $DEBUG = true
      end
      opt.on_tail('--help') do
        puts opt
        exit 0
      end
    end
  end

  #
  def self.root?
    root = false
    root = true if File.exist?('.ruby')
    root = true if File.exist?('.yardoc')
    root = true if File.exist?('.git')
    root = true if File.exist?('.hg')
    root
  end

end
