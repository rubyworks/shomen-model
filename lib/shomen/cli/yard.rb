module Shomen

  module CLI

    require 'shomen/cli/abstract'

    # TODO: Convert YARD CLI into a YARD plugin, possible?

    # YARD command line interface.
    #
    # Unlike the RDoc command, this passes ARGV on to YARD's actual CLI interface,
    # so all YARD commandline options are supported, albeit some options have
    # no baring on the generation of a Shomen model).
    #
    # The yard command provides a utility to generate
    # a Shomen doc file using YARD's .yardoc cache.
    #
    class YARDCommand < Abstract

      #
      def self.cli(*argv)
        new(*argv)
      end

      # New Shomen YARD command line interface.
      def initialize(*argv)
        super(*argv)
      end

      #
      def run(*argv)
        require 'shomen/yard'

        #force = argv.delete('--force')

        if !(force? or root?)
          $stderr.puts "ERROR: Not a project directory. Use --force to override."
          exit -1
        end

        #options = {}
        #parser = parser(:format, :source, options)
        #parser.order!(argv)
        #argv = parser.permute(argv)
        #options[:format] = extact_option(argv, :format, :f, 'json')

        argv.unshift('-n')  # do not generate yard documentation
        argv.unshift('-q')  # supress yard's usual output

        # clear the registry in memory to remove any previous runs
        YARD::Registry.clear

        yard = YARD::CLI::Yardoc.new
        yard.run(*argv)

        files    = yard.options[:files].map(&:filename) + yard.files
        database = yard.options[:db]
        #yardopts = yard.options[:yardopts]

        options = {}
        #options[:format] = format
        options[:files]  = files
        options[:db]     = database

        #options = parse(argv, :yaml, :clear, :db, :yardopts, :force, defaults)

        yard = Shomen::YardAdaptor.new(options)
        yard.generate

        case options[:format]
        when 'yaml'
          $stdout.puts(yard.table.to_yaml)
        else
          $stdout.puts(force_encoding(yard.table).to_json)
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

      #
      #def extact_option(argv, name, short, default)
      #  if i = argv.index("--#{name}") || argv.index("-#{short}")
      #    argv.delete_at(i)
      #    argv.delete_at(i)
      #  else
      #    default
      #  end
      #end

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

end
