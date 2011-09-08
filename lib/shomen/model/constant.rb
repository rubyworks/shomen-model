module Shomen

  module Model

    require 'shomen/model/abstract'

    #
    class Constant < Abstract
      #
      def self.type; 'constant'; end

      # Constant's basename, must start with a capitalized letter.
      attr_accessor :name

      #
      attr_accessor :namespace

      #
      attr_accessor :comment

      #
      attr_accessor :value
    end

  end

end
