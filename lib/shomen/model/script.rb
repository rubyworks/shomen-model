module Shomen

  module Model

    require 'shomen/model/document'

    #
    class Script < Document
      #
      def self.type; 'script'; end

      attr_accessor :source

      # Route text to source.
      alias :text  :source
      alias :text= :source=

      # Source code URI.
      attr_accessor :uri

      #
      attr_accessor :language

      #
      attr_accessor :name

      attr_accessor :path

      attr_accessor :mtime

      attr_accessor :header

      attr_accessor :footer

      attr_accessor :requires

      attr_accessor :constants

      attr_accessor :modules

      attr_accessor :classes

      attr_accessor :class_methods

      attr_accessor :methods

    end

  end

end
