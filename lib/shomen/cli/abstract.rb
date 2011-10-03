module Shomen

  begin; gem 'json'; rescue; end

  require 'optparse'
  require 'yaml'
  require 'json'

  module CLI

    # Command line interface base class.
    #
    class Abstract

      #
      def self.run(*arg)
        new.run(*argv)
      end

      #
      def parse(argv, *choices)
        options = (Hash === choices.last ? choices.pop : {})
        parser  = OptionParser.new

        choices.each do |choice|
          send("option_#{choice}", parser, options)
        end
        option_debug(parser, options)
        option_warn(parser, options)
        option_help(parser, options)

        parser.parse!(argv)

        return options
      end

=begin
      #
      def option_yaml(parser, options)
        parser.on('-y', '--yaml', 'output YAML instead of JSON') do
          options[:format] = 'yaml'
        end
      end

      #
      def option_json(parser, options)
        parser.on('-j', '--json', 'output JSON instead of YAML (default)') do
          options[:format] = 'json'
        end
      end
=end

      #
      def option_format(parser, options)
        parser.on('-f', '--format NAME') do |format|
          options[:format] = format
        end
      end

      #
      def option_source(parser, options)
        parser.on('-s', '--[no-]source', 'include full source in script documentation') do |bool|
          Shomen.source = bool
        end
      end

      #
      def option_force(parser, options)
        parser.on('-f', '--force') do
          options[:force] = true
        end
      end

      #
      def option_debug(parser, options)
        parser.on_tail('-D', '--debug', 'run with $DEBUG set to true') do
          $DEBUG = true
        end
      end

      #
      def option_warn(parser, options)
        parser.on_tail('-W', '--warn', 'run with $VERBOSE set to true') do
          $VERBOSE = true
        end
      end

      #
      def option_help(parser, options)
        parser.on_tail('--help') do
          puts opt
          exit 0
        end
      end

      #
      def root?
        root = false
        root = true if File.exist?('.ruby')
        root = true if File.exist?('.yardoc')
        root = true if File.exist?('.git')
        root = true if File.exist?('.hg')
        root
      end

    end

  end

  #
  def self.source?
    @source
  end

  #
  def self.source=(bool)
    @source = bool
  end

end
