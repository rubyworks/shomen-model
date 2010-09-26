#$:.unshift File.dirname(__FILE__)

#begin

#  require "rubygems"
#  gem "rdoc", ">= 2.4.2"

#  require "rdoc/rdoc"

  #module RDocShomen
  #  DIRECTORY = File.dirname(__FILE__)
  #  VERSION   = "0.1.0"  #:till: VERSION="<%= version %>"
  #end

#  require "rdoc/c_parser_fix"

  require "rdoc/generator/shomen"

=begin
  unless defined?($SHOMEN_FIXED_RDOC_OPTIONS)
    $SHOMEN_FIXED_RDOC_OPTIONS = true

    class RDoc::Options
      #alias_method :rdoc_initialize, :initialize
      #def initialize
      #  rdoc_initialize
      #  @generator = RDoc::Generator::RDazzle
      #end

      alias_method :rdoc_parse, :parse

      def parse(argv)
        rdoc_parse(argv)
        #begin
puts "Shomen: #{@template}" #if $DEBUG
        if @template == 'shomen'
          require "rdoc-shomen/generator"
          @generator = RDocShomen::Generator
        end
        #rescue LoadError
        #end
      end
    end

  end
=end

#rescue Exception
#  warn "Shomen requires RDoc v2.4.2 or greater."

#end

