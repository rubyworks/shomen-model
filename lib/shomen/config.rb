module Shomen

  # Extend Shomen namespace with global configuration attribtes.
  #
  module Configurable

    #
    # Include raw source code in documentation?
    #
    def source?
      @source
    end

    #
    # Set source configuration to `true` if documentation should include
    # full source code. Generally, this is a bad idea since it will make
    # the generated file rather huge. But for small projects it may be a
    # prefectly good choice. For large projects a better approach is to
    # provide a `webcvs` URI.
    #
    def source=(bool)
      @source = bool
    end

    #
    # URI that can be used to link documentation to on-line
    # source code browsing.
    #
    def webcvs
      @webcvs
    end

    #
    # Set the URI for linking to to on-line source code browser.
    #
    def webcvs=(uri)
      @webcvs = uri
    end

  end

  extend Configurable

end
