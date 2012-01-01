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
      def usual_parser(argv, *choices)
        choices = [:debug, :warn, :help] + choices
        parser(*choices)
      end

      #
      def parser(*choices)
        parser  = OptionParser.new
        options = choices.pop

        choices.each do |choice|
          send("option_#{choice}", parser, options)
        end

        parser
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
        parser.on('-s', '--source', 'include full source in script documentation') do
          Shomen.source = true
        end
        parser.on('-u', '--scm-uri URI', 'link to source code via SCM URI') do |uri|
          Shomen.scm_uri = uri
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
          puts parser
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

  # TODO: Rather source and source_uri not be global, but we have a problem getting them
  # into the RDoc Generator. Need to figure out how to get these in some
  # way via initializer.

  #
  def self.source?
    @source
  end

  #
  def self.source=(bool)
    @source = bool
  end

  #
  def self.scm_uri
    @scm_uri
  end

  #
  def self.scm_uri=(uri)
    @scm_uri = uri
  end

end
