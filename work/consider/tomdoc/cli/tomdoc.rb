module Shomen

  require 'shomen/cli/abstract'

  module CLI

    # RDoc command line interface.
    class TomDocCommand < Abstract

      #
      def self.run(*argv)
        new.run(argv)
      end

      # New Shomen TomDoc command line interface.
      def initialize
      end

      #
      def run(argv)
        require 'shomen/tomdoc'

        defaults = {}
        defaults[:format]  = 'json'
        defaults[:force]   = false
        defaults[:source]  = true

        options = parse(argv, :format, :force, :visibility, :main, :source, defaults)

        if !options[:force] && !root?
          $stderr.puts "Not a project directory. Use --force to override."
          exit -1
        end

        if argv.empty?
          if File.exist?('.document')
            files = File.read('.document').split("\n")
            files = files.reject{ |f| f.strip == '' or f.strip =~ /^\#/ }
            files = files.map{ |f| Dir[f] }.flatten
          else
            files = ['lib']
          end
        else
          files = argv
        end

        # TODO: limit extensions of files
        files = files.map{ |f| File.directory?(f) ? Dir[File.join(f, '**/*')] : f }.flatten

        main       = options[:main] || Dir.glob('{README.*,README}').first
        visibility = options[:visibility].to_s
        format     = options[:format]

        case format
        when 'json', 'yaml'
        else
          $stderr.puts "ERROR: Format must be 'yaml` or 'json`."
          exit -1
        end

        argf = argf(files)

        tomdoc = TomDoc::Generators::Shomen.new() #@options) ignore and pattern
        tomdoc.generate(argf.read)

        case format
        when 'yaml'
          $stdout.puts(tomdoc.table.to_yaml)
        else
          $stdout.puts(tomdoc.table.to_json)
        end
      end

      # ARGF faker.
      def argf(files)
        buffer = ''

        files.select{ |arg| File.exists?(arg) }.each do |file|
          buffer << File.read(file)
        end

        require 'stringio'
        StringIO.new(buffer)
      end

=begin
      on "-n", "--pattern=PATTERN",
        "Limit results to strings matching PATTERN." do |pattern|

        @options[:pattern] = pattern
      end

      on "-i", "--ignore",
        "Ignore validation, print all methods we find with comments.." do

        @options[:validate] = false
      end
=end

      #
      def option_visibility(parser, options)
        parser.on('-v', '--visibility TYPE') do |type|
          options[:visibility] = type
        end
      end

      #
      def option_main(parser, options)
        parser.on('-m', '--main FILE') do |file|
          options[:main] = file
        end
      end

    end

  end

end

