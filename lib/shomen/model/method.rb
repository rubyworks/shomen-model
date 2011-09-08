module Shomen

  module Model

    require 'shomen/model/abstract'

    #
    class Method < Abstract

      #
      def initialize(settings={})
        super(settings)
        self['!'] = settings['singleton'] ? 'function' : 'method'
      end

      # Method's name.
      attr_accessor :name

      # Method's namespace.
      attr_accessor :namespace

      # Comment accompanying method definition.
      attr_accessor :comment

      # Visibility: 'public', 'protected' or 'private'.
      attr_accessor :access

      # Singleton method?
      attr_accessor :singleton

      # Aliases.
      attr_accessor :aliases

      # Aliases.
      attr_accessor :alias_for

      # Interface literal image.
      attr_accessor :image #

      # Arguments breakdown.
      attr_accessor :arguments

      # Parameters breakdown.
      attr_accessor :parameters

      # Block
      attr_accessor :block

      # Interface
      attr_accessor :interface

      # Returns
      attr_accessor :returns

      # Filename.
      attr_accessor :file

      # Line number.
      attr_accessor :line

      # Source code.
      attr_accessor :source

      # Deprecated method.
      alias :parent :namespace

    end

  end

end
