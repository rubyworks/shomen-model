module Shomen

  module Model

    require 'shomen/model/abstract'
    require 'shomen/model/interface'

    #
    class Method < Abstract

      #
      def initialize(settings={})
        super(settings)
        @table['declarations'] ||= []
      end

      # Method's name.
      attr_accessor :name

      # Method's namespace.
      attr_accessor :namespace

      # Comment accompanying method definition.
      attr_accessor :comment

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

      # Singleton method `true` or `false/nil`.
      attr_accessor :singleton

      # Delarations is a list of keywords that designates characteristics
      # about a method. Common characteristics include `reader`, `writer`
      # or `accessor` if the method is defined via an attr method; `public`
      # `private` or `protected` given the methods visibility; and `class`
      # or `instance` given the methods scope. Default designations are
      # are impled if not specifically stated, such as `public` and `instance`.
      #
      # Using a declarations list simplifies the Shomen data format by allowing
      # declarations to be freely defined, rather than creating a field for each
      # possible designation possible.
      attr_accessor :declarations

      # Aliases.
      attr_accessor :aliases

      # Aliases.
      attr_accessor :alias_for

      # Breakdown of interfaces signature, arguments, parameters, block argument
      # an return values.
      attr_accessor :interfaces

      #
      def interfaces=(array)
        self['interfaces'] = (
          array.map do |settings|
            case settings
            when Interface
              settings
            else
              Interface.new(settings)
            end
          end
        )
      end

      # List of possible returns types.
      attr_accessor :returns

      # List of possible raised errors.
      attr_accessor :raises

      # Method generated dynamically?
      attr_accessor :dynamic

      # Filename.
      attr_accessor :file

      # Line number.
      attr_accessor :line

      # Source code.
      attr_accessor :source

      # Source code language.
      attr_accessor :language


      # Deprecated method.
      alias :parent :namespace

      #
      def to_h
        h = super
        h['!'] = 'method'
        h['interfaces'] = (interfaces || []).map{ |s| s.to_h }
        h
      end
    end

  end

end
