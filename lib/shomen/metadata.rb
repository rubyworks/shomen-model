require 'yaml'

module Shomen

  # Encapsulate metadata, which preferably comes from a .ruby file,
  # but can fallback to a gemspec.
  #
  class Metadata
    include Enumerable

    #
    def initialize
      @data = (
        if file = File.file?('.ruby')
          YAML.load_file('.ruby')
        elsif file = Dir['{,*}.gemspec'].first
          # prefereably use dotruby library to convert,
          # but wait until it's more mainstream
          require 'rubygems/specification'
          spec = ::Gem::Specification.load(file)
          {
            'name'        => spec.name,
            'version'     => spec.version.to_s,
            'authors'     => [spec.author],
            'description' => spec.description,
            'summary'     => spec.summary,
            'resources'   => {
              'homepage'  => spec.homepage
            }
          }
        else
          {
            'name' => File.basename(Dir.pwd)
          }
        end
      )
    end

    #
    def [](name)
      @data[name]
    end

    #
    def size
      @data.size
    end

    #
    def each(&blk)
      @data.each(&blk)
    end

    #
    def to_h
      @data
    end

  end

end
