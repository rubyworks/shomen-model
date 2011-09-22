module Shomen

  module Model

    require 'shomen/model/abstract'
    require 'shomen/model/signature'

    #
    class Method < Abstract

      #
      def initialize(settings={})
        super(settings)
      end

      # Method's name.
      attr_accessor :name

      # Method's namespace.
      attr_accessor :namespace

      # Comment accompanying method definition.
      attr_accessor :comment

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

      # Visibility: 'public', 'protected' or 'private'.
      attr_accessor :access

      # Singleton method?
      attr_accessor :singleton

      # Can be nil, 'r', 'w', 'rw'.
      attr_accessor :accessor

      # Aliases.
      attr_accessor :aliases

      # Aliases.
      attr_accessor :alias_for

      # Interfaces images and argument breakdowns.
      attr_accessor :signatures

      #
      def signatures=(array)
        self['signatures'] = (
          array.map do |settings|
            case settings
            when Signature
              settings
            else
              Signature.new(settings)
            end
          end
        )
      end

      # Returns
      attr_accessor :returns

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
        h['!'] = singleton ? 'class-method' : 'method'
        h['signatures'] = (signatures || []).map{ |s| s.to_h }
        h
      end
    end

  end

end
