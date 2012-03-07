module Shomen

  require 'shomen/cli/abstract'
  #require 'tmpdir'

  module CLI

    # RDoc command line tool provides a utility to generate a Shomen doc
    # file using RDoc's .rdoc cache.
    #
    # RDocCommand passes ARGV on to RDoc's actual CLI interface, so all RDoc
    # command line options are supported, albeit some options have no baring
    # on the generation of a Shomen model.
    #
    class RDocCommand < Abstract

      #
      def self.cli(*argv)
        new(*argv)
      end

      # New RDoc command line interface.
      def initialize(*argv)
        super(*argv)

        begin
          gem 'rdoc'
        rescue
        end
      end

      #
      def run(*argv)
        require 'shomen/rdoc'

        if !(force? || root?)
          $stderr.puts "Not a project directory. Use --force to override."
          exit -1
        end

        #if argv.empty?
        #  if File.exist?('.document')
        #    files = File.read('.document').split("\n")
        #    files = files.reject{ |f| f.strip == '' or f.strip =~ /^\#/ }
        #    files = files.map{ |f| Dir[f] }.flatten
        #  else
        #    files = ['lib']
        #  end
        #else
        #  files = argv
        #end

        #argv.unshift('-n')  # do not generate yard documentation
        argv.unshift('-q')  # supress yard's usual output

        #tmpdir = File.join(Dir.tmpdir, 'shomen-rdoc')  # '/dev/null'
        #main   = Dir.glob('{README.*,README}').first

        # remove 'rdoc'
        #argv.shift

        # must be quiet
        #argv = ['-q'] + argv

        # divert output to no where
        remove_options(argv, '-o', '--output')
        argv = ['-o', tmpdir] + argv

        # provide main if not given
        # argv = ['-m', main] + argv unless argv.include?('-m') || argv.include?('--main') 

        # provide tiel if not given ?
        #argv = ['-t', title] + argv

        # TODO: force the inclusion of all methods ?
        #rdoc_options += ['-V', 'private']
     
        # format is shomen, of course
        remove_options(argv, '-f', '--format')
        argv = ['-f', 'shomen'] + argv

        # TODO: Any way to supress the cretion of the time stamp altogether?
        # Options#update_output_dir for instance?

        rdoc = ::RDoc::RDoc.new
        rdoc.document(argv)

        case format
        when :yaml
          $stdout.puts(rdoc.generator.shomen.to_yaml)
        else
          $stdout.puts(JSON.generate(rdoc.generator.shomen))
        end
      end

      #
      #def option_visibility(parser, options)
      #  parser.on('--private', 'include public, protected and private methods') do
      #    options[:visibility] = :private
      #  end
      #  parser.on('--protected', 'include public and protected methods') do
      #    options[:visibility] = :protected
      #  end
      #end

      #
      #def option_document(parser, options)
      #  parser.on('--document FILE') do |file|
      #    options[:document] = file
      #  end
      #end

      #
      #def option_main(parser, options)
      #  parser.on('-m', '--main FILE') do |file|
      #    options[:main] = file
      #  end
      #end
    end

  end

end
