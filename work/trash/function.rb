module Shomen

  module Model

    require 'shomen/model/method'

    #
    class Function < Method
      #
      def self.type; 'function'; end

      #
      def initialize(settings={})
        super(settings)
        settings['singleton'] = true
      end

      #
      def singleton=(x)
        raise "error: functions are singleton" unless x
      end

    end

  end

end
