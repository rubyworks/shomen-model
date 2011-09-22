module Shomen

  module Model
    require 'shomen/model/module'

    #
    class Class < Module

      #
      def self.type; 'class'; end

      #
      attr_accessor :superclass

    end

  end

end
