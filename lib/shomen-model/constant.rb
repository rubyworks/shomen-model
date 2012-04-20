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

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

      #
      attr_accessor :value

      #
      attr_accessor :files

    end

  end

end
