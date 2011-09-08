module Shomen

  module Model

    # Baseclass for all model classes.
    #
    class Abstract
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
        @table = { '!' => self.class.type }
        settings.each do |k,v|
          __send__("#{k}=",v)
        end
      end

      # Full name.
      attr_accessor :key

      #
      alias :fullname :key

      # Type is always 'constant'.
      def type
        self['!']
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
        @table.dup
      end

    end

  end

end
