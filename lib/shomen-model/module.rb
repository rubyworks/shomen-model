module Shomen

  module Model

    #
    class Module < Abstract

      #
      def self.type; 'module'; end

      # Method's name.
      attr_accessor :name

      # Namespace of module is the path of the class or module
      # containing this module.
      attr_accessor :namespace

      # Comment associated with module.
      attr_accessor :comment

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

      # Mixins.
      attr_accessor :includes

      # Metaclass mixins.
      attr_accessor :extensions

      # Constants defined within this module.
      attr_accessor :constants

      #
      attr_accessor :modules

      #
      attr_accessor :classes

      # List of instance methods defined in the module.
      attr_accessor :methods

      # List of attributes.
      attr_accessor :accessors

      # The files in which the module is defined.
      attr_accessor :files

      #
      alias :fullname :path
    end

  end

end
