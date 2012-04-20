module Shomen

  require 'shomen/core_ext/hash'

  module Model

    # Base class for all model classes.
    #
    class AbstractPrime

      # Models use an internal hash to store attributes instead of 
      # the usual instance methods.
      #
      # Returns nothing.
      def self.attr_accessor(name)
        name = name.to_s
        define_method(name) do
          self[name]
        end
        define_method(name+'=') do |x|
          self[name] = x
        end
      end

      # Module type is the "last name" of the module downcased.
      #
      # Returns String of module type.
      def self.type
        name.split('::').last.downcase
      end

      # Initialize new instance of model.
      #
      # settings - Hash of attribute settings.
      #
      # Returns new model instance.
      def initialize(settings={})
        @table = {}
        settings.each do |k,v|
          s = "#{k}=".gsub('-','_')
          __send__(s,v)
        end
      end

      # Fetch attribute.
      #
      # key - String of attribute's name.
      #
      # Returns attribute value.
      def [](key)
        @table[key.to_s]
      end

      # Store attribute.
      #
      # key   - String of attribute's name.
      # value - Object as value of attribute.
      #
      # Returns attribute value.
      def []=(k,v)
        @table[k.to_s] = v
      end

      # Convert attributes to hash, including all nested object
      # that repsond to #to_h.
      #
      # Returns Hash of attribute's key-value pairs.
      def to_h
        t = {}
        @table.each do |k,v|
          if v.respond_to?(:to_h)
            t[k] = v.to_h
          else
            t[k] = v
          end
        end
        t
      end

    end

    # Abstract base class for model classes that have a type field,
    # i.e. a `!` field. 
    #
    class Abstract < AbstractPrime

      # Initialize new model instance.
      def initialize(settings={})
        super(settings)
        @table['!'] = self.class.type
      end

      # Full path name of documentation entry.
      #
      # Returns String.
      attr_accessor :path

      # Hash of `label => description`.
      #
      # Returns Hash.
      attr_accessor :tags

      # Type of documentation entry. Valid types are `document`,
      # `script`, `method`, `class_method`, `constant` and, for one
      # entry only, `(metadata)`.
      #
      # Retuns String of documentation entry type.
      def type
        self['!']
      end

    end

  end

end
