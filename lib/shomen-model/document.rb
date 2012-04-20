module Shomen

  module Model

    #
    class Document < Abstract
      #
      def self.type
        'document'
      end

      #def key=(path)
      #  path = '/' + path unless path[0,1] == '/'
      #  super(path)
      #end

      attr_accessor :name

      #attr_accessor :parent

      attr_accessor :path

      # Time stamp when script was last modifed.
      attr_accessor :modified

      alias :mtime :modified
      alias :mtime= :modified=

      # Time stamp when script was first created.
      attr_accessor :created

      alias :ctime :created
      alias :ctime= :created=

      # Source code URI.
      attr_accessor :uri

      #
      attr_accessor :text

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

    end

  end

end
