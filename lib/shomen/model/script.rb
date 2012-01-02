module Shomen

  module Model

    require 'shomen/model/document'

    #
    class Script < Document
      #
      def self.type; 'script'; end

      # Full source code or +nil+ if not provided.
      attr_accessor :source

      # Route text to source.
      alias :text  :source
      alias :text= :source=

      # TODO: Since we are making source available should we deprecate header and footer,
      # or should we include it if source is excluded ?

      attr_accessor :header

      attr_accessor :footer

      # Source code URI.
      attr_accessor :uri

      # The lanuage of the script.
      attr_accessor :language

      # File basename of script path.
      attr_accessor :name

      # Full path of script, relative to project root.
      attr_accessor :path

      # TODO: Rename mtime to modified.

      # Time stamp when script was last modifed.
      attr_accessor :mtime

      alias :modified, :mtime
      alias :modified=, :mtime=

      # Time stamp when script was first created.
      attr_accessor :created

      alias :ctime, :created
      alias :ctime=, :created=

      # Other scripts required by this script.
      attr_accessor :requires

      # TODO: Presently these are not being fully utilized by the parsers, need to fix.

      # Constants defined by this script.
      attr_accessor :constants

      # Modules defined by this script.
      attr_accessor :modules

      # Classes defined by this script.
      attr_accessor :classes

      # Class methods defined in this script.
      attr_accessor :class_methods

      # Methods defined in this script.
      attr_accessor :methods

    end

  end

end
