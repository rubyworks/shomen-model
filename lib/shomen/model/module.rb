module Shomen

  module Model

    require 'shomen/model/abstract'

    #
    class Module < Abstract
      #
      def self.type; 'module'; end

      # Full name.
      attr_accessor :key

      # Method's name.
      attr_accessor :name

      #
      attr_accessor :namespace

      #
      attr_accessor :comment

      #
      attr_accessor :includes

      #attr_accessor :extended  # TODO: how?

      #
      attr_accessor :constants

      #
      attr_accessor :modules

      #
      attr_accessor :classes

      #
      attr_accessor :functions

      # Also known as `properties`.
      attr_accessor :attributes

      attr_accessor :class_attributes

      #
      attr_accessor :methods

      #
      attr_accessor :files

      #
      alias :fullname :key
    end

  end

end
