module Shomen

  begin; gem 'json'; rescue; end

  require 'shomen/cli/abstract'
  require 'tmpdir'
  require 'json'

  module CLI

    # RDoc command line interface.
    class RDocCommand < Abstract

      #
      def self.run(*argv)
        new.run(argv)
      end

      # New RDoc command line interface.
      def initialize
        begin
          gem 'rdoc'
        rescue
        end
      end

      #
      def run(argv)
        require 'shomen/rdoc'

        defaults = {}
        defaults[:format]  = :json
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

        tmpdir     = File.join(Dir.tmpdir, 'shomen-rdoc')
        main       = options[:main] || Dir.glob('{README.*,README}').first
        visibility = options[:visibility].to_s

        # TODO: Any way to supress the cretion of the time stamp altogether?
        # Options#update_output_dir for instance?

        # TODO: Using the ::RDoc::Options doesn't seem to work.
        # It complains about a template being nil in `rdoc/options.rb:760`.

        #rdoc_options = ::RDoc::Options.new
        #rdoc_options.generator = 'shomen'
        #rdoc_options.main_page = Dir.glob('README*').first
        ##rdoc_options.template  = 'shomen'
        ##rdoc_options.template_dir = File.dirname(__FILE__)
        #rdoc_options.op_dir    = 'tmp/rdoc'  # '/dev/null'
        #rdoc_options.files     = files

        rdoc_options  = []
        rdoc_options += ['-q']
        #rdoc_options += ['-t', title]
        rdoc_options += ['-f', 'shomen']
        rdoc_options += ['-m', main] if main
        rdoc_options += ['-V', visibility]
        rdoc_options += ['-o', tmpdir]  # '/dev/null'
        rdoc_options += files

        rdoc = ::RDoc::RDoc.new
        rdoc.document(rdoc_options)

        case options[:format]
        when :yaml
          $stdout.puts(rdoc.generator.shomen.to_yaml)
        else
          $stdout.puts(JSON.generate(rdoc.generator.shomen))
        end
      end

      #
      def option_visibility(parser, options)
        parser.on('--private', 'include public, protected and private methods') do
          options[:visibility] = :private
        end
        parser.on('--protected', 'include public and protected methods') do
          options[:visibility] = :protected
        end
      end

      #
      #def option_document(parser, options)
      #  parser.on('--document FILE') do |file|
      #    options[:document] = file
      #  end
      #end

      #
      def option_main(parser, options)
        parser.on('-m', '--main FILE') do |file|
          options[:main] = file
        end
      end

      # TODO: Add support for additional options supported by rdoc.
    end

  end

end
