module Shomen

  require 'shomen/cli/abstract'
  require 'tmpdir'

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

        options = parse(argv, :yaml, :json, :force, :visibility, defaults)

        if !options[:force] && !root?
          $stderr.puts "Not a project directory. Use --force to override."
          exit -1
        end

        if argv.empty?
          if File.exist?('.document')
            files = File.read('.document').split("\n")
            files.reject!{ |f| f.strip == '' }
          else
            files = ['lib']
          end
        else
          files = argv
        end

        visibility = options[:visibility].to_s
        main       = Dir.glob('README*').first
        tmpdir     = File.join(Dir.tmpdir, 'shomen-rdoc')

        # TODO: Any way to supress the cretion of the time stamp altogether?
        # Options#update_output_dir for instance?

        # FIXME: Using the ::RDoc::Options doesn't seem to work.
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
        rdoc_options += ['-o', tmpdir]  # '/dev/null'
        rdoc_options += ['-V', visibility]  # '/dev/null'
        rdoc_options += files

        rdoc = RDoc::RDoc.new
        rdoc.document(rdoc_options)

        if options[:format] == :yaml
          $stdout.puts rdoc.generator.shomen.to_yaml
        else
          $stdout.puts rdoc.generator.shomen.to_json
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
      #def option_clear(parser, options)
      #  parser.on('-c', '--clear') do
      #    options[:clear] = true
      #  end
      #end

    end

  end

end
