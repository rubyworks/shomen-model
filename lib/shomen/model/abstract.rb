module Shomen

  require 'shomen/core_ext/hash'

  module Model

    # Baseclass for all model classes.
    #
    class AbstractPrime
      #
      def self.attr_accessor(name)
        name = name.to_s
        define_method(name) do
          self[name]
        end
        define_method(name+'=') do |x|
          self[name] = x
        end
      end

      #
      def self.type
        name.split('::').last.downcase
      end

      #
      def initialize(settings={})
        @table = {}
        settings.each do |k,v|
          s = "#{k}=".gsub('-','_')
          __send__(s,v)
        end
      end

      #
      def [](k)
        @table[k.to_s]
      end

      #
      def []=(k,v)
        @table[k.to_s] = v
      end

      #
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

    #
    class Abstract < AbstractPrime

      #
      def initialize(settings={})
        super(settings)
        @table['!'] = self.class.type
      end

      # Full name.
      attr_accessor :path

      # Hash of label => description.
      attr_accessor :tags

      #
      def type
        self['!']
      end

    end

  end

end
