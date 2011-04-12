#
puts "RDoc discovered Shomen!"

# If using Gems put her on the $LOAD_PATH
begin
  require "rubygems"
  gem "rdoc", "~> 2.5"
  gem "shomen"
end

require 'rdoc/option_fix'

=begin
unless defined?($FIXED_RDOC_OPTIONS)
  $FIXED_RDOC_OPTIONS = true

  #
  def RDoc.generator_option(name, &blk)
    @_generators ||= {}
    if blk
      @_generators[name.to_s] = blk
    else
      @_generators[name.to_s]
    end
  end

  #
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
      if blk = RDoc.generator_option(@template)
        @generator = blk.call
      end
      #if @template == 'shomen'
      #  require "rdoc-shomen/generator"
      #  @generator = RDocShomen::Generator
      #end
      #rescue LoadError
      #end
    end
  end
end
=end

RDoc.generator_option('shomen') do
  require 'shoment/rdoc/generator'
  RDoc::Generator::Shomen
end

