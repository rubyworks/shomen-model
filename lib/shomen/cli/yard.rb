module Shomen

  module CLI

    require 'shomen/cli/abstract'

    # YARD command line interface.
    #
    # The yard command provides a utility to generate
    # a Shomen doc file using YARD's .yardoc cache.
    #
    class YARDCommand < Abstract

      #
      def self.run(*argv)
        new.run(argv)
      end

      # New Shomen YARD command line interface.
      def initialize
      end

      #
      def run(argv)
        require 'shomen/yard'

        force = argv.delete('--force')

        if !(force or root?)
          $stderr.puts "ERROR: Not a project directory. Use --force to override."
          exit -1
        end

        format = (
          if i = argv.index('--format') || argv.index('-f')
            argv[i+1]
            argv.delete_at(i)
            argv.delete_at(i)
          else
            'json'
          end
        )

        case format
        when 'json', 'yaml'
        else
          $stderr.puts "ERROR: Format must be 'yaml` or 'json`."
          exit -1
        end

        argv.unshift('-n')  # do not generate yard documentation
        argv.unshift('-q')  # supress yard's usual output

        YARD::Registry.clear  # clear the registry in memory to remove any previous runs

        yard = YARD::CLI::Yardoc.new
        yard.run(*argv)

        files    = yard.options[:files].map(&:filename) + yard.files
        database = yard.options[:db]

        options = {}
        options[:format] = format
        options[:files]  = files
        options[:db]     = database

        #options = parse(argv, :yaml, :clear, :db, :yardopts, :force, defaults)

        yard = Shomen::YardAdaptor.new(options)
        yard.generate

        case format
        when 'yaml'
          $stdout.puts(yard.table.to_yaml)
        else
          $stdout.puts(yard.table.to_json)
        end
      end

      #
      #def option_yaml(parser, options)
      #  parser.on('-y', '--yaml', 'output YAML instead of JSON') do
      #    options[:format] = :yaml
      #  end
      #end

      #
      #def option_clear(parser, options)
      #  parser.on('-c', '--clear') do
      #    options[:clear] = true
      #  end
      #end

      #
      #def option_db(parser, options)
      #  parser.on('-b', '--db DIR') do |dir|
      #    options[:db] = dir
      #  end
      #end

      #
      #def option_yardopts(parser, options)
      #  parser.on('--yardopts FILE') do |file|
      #    options[:yardopts] = file
      #  end
      #end

    end

  end

end
