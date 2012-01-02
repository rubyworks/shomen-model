module Shomen

  begin; gem 'json'; rescue; end

  require 'optparse'
  require 'yaml'
  require 'json'

  # TODO: I think instead of using command line options for shomen
  # we could use environment variables.

  module CLI

    # Command line interface base class.
    #
    class Abstract

      #
      DEFAULT_FORMAT = 'json'

      # Command line options accepted by shomen command.
      SHOMEN_OPTIONS = %w{debug warn help force source format yaml json}

      #
      def initialize(*argv)
        @format = DEFAULT_FORMAT

        parse(argv, *SHOMEN_OPTIONS)
      end

      #
      def parse(argv, *choices)
        parser  = OptionParser.new

        choices.each do |choice|
          send("option_#{choice}", parser)
        end

        parser.parse!(argv)
      end

      #
      def force?
        $FORCE
      end

      #
      attr_accessor :format

      #
      def option_yaml(parser)
        parser.on('-y', '--yaml', 'output YAML instead of JSON') do
          self.format = 'yaml'
        end
      end

      #
      def option_json(parser)
        parser.on('-j', '--json', 'output JSON instead of YAML (default)') do
          self.format = 'json'
        end
      end

      #
      def option_format(parser)
        parser.on('-f', '--format NAME') do |format|
          if not %w{json yaml}.include?(format)
            $stderr.puts "ERROR: Format must be 'yaml` or 'json`."
            exit -1
          end
          self.format = format
        end
      end

      #
      def option_source(parser)
        parser.on('-s', '--source', 'include full source in script documentation') do
          Shomen.source = true
        end
        parser.on('-u', '--scm-uri URI', 'link to source code via SCM URI') do |uri|
          Shomen.scm_uri = uri
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
        parser.on_tail('-d', '--debug', 'run with $DEBUG set to true') do
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

    private

      #
      # Remove setting options from command line arguments.
      #
      def remove_options(argv, *options)
        options.each do |opt|
          i = argv.index(opt)
          if i
            argv.delete_index(i)
            argv.delete_index(i)
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
