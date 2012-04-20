require 'yaml'

module Shomen

  # Encapsulate metadata, which preferably comes from a .ruby file,
  # but can fallback to a gemspec.
  #
  class Metadata
    include Enumerable

    # Present working directoty.
    PWD = Dir.pwd

    # Glob pattern for looking up gemspec.
    GEMSPEC_PATTERN = '{.gemspec,*.gemspec}'

    #
    # Initialize new Metadata instance.
    #
    def initialize
      @data = (
        data = {}
        if dotruby
          data.merge!(YAML.load_file(dotruby))
        elsif gemspec
          # prefereably use dotruby library to convert,
          # but wait until it's more mainstream
          require 'rubygems/specification'
          spec = ::Gem::Specification.load(gemspec)
          data['name']        = spec.name,
          data['title']       = spec.name.capitalize,
          data['version']     = spec.version.to_s,
          data['authors']     = [spec.author],
          data['summary']     = spec.summary,
          data['description'] = spec.description,
          data['resources']   = {'homepage' => spec.homepage}
        else
          # TODO: Raise error instead ?
          data['name'] = File.basename(Dir.pwd)
        end
        data['path']   = '(metadata)'
        data['markup'] = 'rdoc'  # FIXME
        data
      )
    end

    #
    def dotruby
      file = File.join(PWD, '.ruby')
      return nil unless File.exist?(file)
      file
    end

    #
    def gemspec
      file = Dir[File.join(PWD, GEMSPEC_PATTERN)].first
      return nil unless file && File.exist?(file)
      file
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
