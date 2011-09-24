module Shomen

  module Model

    require 'shomen/model/abstract'

    #
    class Interface < AbstractPrime

      # TODO: validate that there is an interface image.
      def initialize(settings={})
        #@table = {'arguments'=>[], 'parameters'=>[]}
        super(settings)
      end

      # The source code "image" of the method's inteface.
      attr_accessor :signature

      # Arguments breakdown.
      attr_accessor :arguments

      # Parameters breakdown.
      attr_accessor :parameters

      # Block
      attr_accessor :block

      # Return value.
      attr_accessor :returns

    end

  end

end
