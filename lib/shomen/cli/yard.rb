module Shomen

  module CLI

    require 'shomen/cli/abstract'

    # YARD command line interface.
    class YARDCommand < Abstract

      #
      def self.run(*argv)
        new.run(argv)
      end

      # Command line interface. (YARD oriented for now).
      #
      def initialize
      end

      # The yard command provides a utility to generate
      # a Shomen doc file using YARD's .yardoc cache.
      #
      def run(argv)
        require 'shomen/yard'

        defaults = {}
        defaults[:format]  = :json
        defaults[:force]   = false
        defaults[:clear]   = false

        options = parse(argv, :yaml, :clear, :db, :yardopts, :force, defaults)

        if !options[:force] && !root?
          $stderr.puts "Not a project directory. Use --force to override."
          exit -1
        end

        yard = Shomen::YardAdaptor.new(options)
        yard.generate

        if options[:format] == :yaml
          $stdout.puts yard.table.to_yaml
        else
          $stdout.puts yard.table.to_json
        end
      end

      #
      def option_yaml(parser, options)
        parser.on('-y', '--yaml', 'output YAML instead of JSON') do
          options[:format] = :yaml
        end
      end

      #
      def option_clear(parser, options)
        parser.on('-c', '--clear') do
          options[:clear] = true
        end
      end

      #
      def option_db(parser, options)
        parser.on('-b', '--db DIR') do |dir|
          options[:db] = dir
        end
      end

      #
      def option_yardopts(parser, options)
        parser.on('--yardopts FILE') do |file|
          options[:yardopts] = file
        end
      end

    end

  end

end
