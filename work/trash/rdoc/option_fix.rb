# This patch to RDoc::Option makes it possible use different
# templates by registering them like this:
#
#   RDoc.generator_option('shomen') do
#     require 'rdoc/generator/shomen'
#     RDoc::Generator::Shomen
#   end
#
# The block simply needs to return the custom generator class.

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
    alias_method :rdoc_parse, :parse

    def parse(argv)
      rdoc_parse(argv)
      begin
        if blk = RDoc.generator_option(@template)
          @generator = blk.call
        end
      rescue Exception => err
        $stderr.puts "problem loading template #{@template} --falling back to default"
      end
    end
  end

end

=begin
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

