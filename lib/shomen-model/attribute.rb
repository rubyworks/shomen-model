module Shomen

  module Model

    require 'shomen/model/method'

    #
    class Attribute < Method
      #
      def self.type; 'attribute'; end

      #
      def initialize(settings={})
        super(settings)
        self['!'] = settings['singleton'] ? 'class-attribute' : 'attribute'
      end

      # 'R', 'W' or 'RW'
      attr_accessor :rw

    end

  end

end
