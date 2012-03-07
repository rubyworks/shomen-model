module Shomen

  # Extend Shomen namespace with global configuration attribtes.
  #
  module Configurable

    # TODO: Rather source and source_uri not be global, but we have a problem getting them
    # into the RDoc Generator. Need to figure out how to get these in some
    # way via initializer.

    #
    def source?
      @source
    end

    #
    def source=(bool)
      @source = bool
    end

    #
    def webcvs
      @webcvs
    end

    #
    def webcvs=(uri)
      @webcvs = uri
    end

  end

  extend Configurable

end
