module Shomen

  # Extend Shomen namespace with global configuration attribtes.
  #
  module Configurable

    # Public: Include raw source code in documentation?
    #
    # Returns true/false.
    def source?
      @source
    end

    # Public: Set source configuration to `true` if documentation should include
    # full source code. Generally, this is a bad idea since it will make
    # the generated file rather huge. But for small projects it may be a
    # prefectly good choice. For large projects a better approach is to
    # provide a `webcvs` URI.
    #
    # Returns true/false.
    def source=(bool)
      @source = !!bool
    end

    # Public: URI that can be used to link documentation to on-line
    # source code browsing.
    #
    # Returns URI or nil.
    def webcvs
      @webcvs
    end

    # Public: Set the URI for linking to online source code browser.
    #
    # Returns String of URI.
    def webcvs=(uri)
      @webcvs = uri.to_s
    end

  end

  extend Configurable

end
