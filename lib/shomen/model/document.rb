module Shomen

  module Model

    require 'shomen/model/abstract'

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

      attr_accessor :mtime

      attr_accessor :text

      # Format of comment (rdoc, markdown or plain).
      attr_accessor :format

    end

  end

end
