module Shomen

  module Model

    require 'shomen/model/abstract'

    #
    class Document < Abstract
      #
      def self.type; 'file'; end  # file ?

      def key=(path)
        path = '/' + path unless path[0,1] == '/'
        super(path)
      end

      attr_accessor :name

      attr_accessor :parent

      attr_accessor :path

      attr_accessor :mtime

      attr_accessor :text

    end

  end

end
