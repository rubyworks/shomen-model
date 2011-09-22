require 'yaml'

module Shomen

  # Encapsulate metadata, which preferably comes from a .ruby file,
  # but can fallback to a gemspec.
  #
  class Metadata
    include Enumerable

    # Present working directoty.
    PWD = Dir.pwd

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
          data['description'] = spec.description,
          data['summary']     = spec.summary,
          data['resources']   = {'homepage' => spec.homepage}
        else
          data['name'] = File.basename(Dir.pwd)
        end
        data['path'] = '(metadata)'
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
      file = Dir[File.join(PWD, '{,*}.gemspec')].first
      return nil unless File.exist?(file)
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


  #
  def generate_metadata(table)
    begin
      #require 'pom/project'
      generate_metadata_from_spec(table)
    rescue Exception => error
      puts error
      begin
        if spec = Dir['*.gemspec'].first
          require 'rubygems/specification'
          generate_metadata_from_gemspec(table)
        end
      rescue Exception
        debug_msg "Could not find any meatadata."
      end
    end
  end

  #
  SPEC_GLOB = '{.ruby,.rubyspec}'

  #
  def generate_metadata_from_spec(table)
    file = Dir[path_base + SPEC_GLOB].first
    data = YAML.load(File.new(file))
    table['(metadata)'] = {
      "!"           => "metadata",
      "name"        => data['name'],
      "version"     => data['version'],
      "title"       => data['title'],
      "summary"     => data['summary'],
      "description" => data['description'],
      "contact"     => data['contact'],
      "resources"   => data['resources'],
      "markup"      => 'rdoc'
    }
  end

  #
  #def generate_metadata_from_pom(table)
  #  project = POM::Project.new
  #  table['(metadata)'] = {
  #    "!"           => "metadata",
  #    "name"        => project.name,
  #    "version"     => project.version,
  #    "title"       => project.title,
  #    "summary"     => project.metadata.summary,
  #    "description" => project.metadata.description,
  #    "contact"     => project.metadata.contact,
  #    "homepage"    => project.metadata.resources.home
  #  }
  #end

  #
  GEMSPEC_GLOB = '{.gemspec,*.gemspec}'

  # Metadata follows the .ruby specification.
  def generate_metadata_from_gemspec(table)
    file = Dir[path_base + GEMSPEC_GLOB].first
    spec = RubyGems::Specification.new(file)  #?
    table['(metadata)'] = {
      "!"           => "metadata",
      "key"         => "(metadata)",
      "name"        => spec.name,
      "title"       => spec.name.upcase,
      "version"     => spec.version.to_s,
      "summary"     => spec.summary,
      "description" => spec.description,
      "contact"     => spec.email,
      "resources"   => { "homepage" => spec.homepage },
      "markup"      => 'rdoc'
    }
  end

  #
  #def metadata
  #  @metadata ||= get_metadata
  #end

  # TODO: Need a better way to determine if POM::Metadata exists.
  #def get_metadata
  #  data = OpenStruct.new
  #  begin
  #    require 'gemdo/metadata'
  #    pom = GemDo::Metadata.new(path_base)
  #    raise LoadError unless pom.name
  #    data.title       = pom.title
  #    data.version     = pom.version
  #    data.subtitle    = nil #pom.subtitle
  #    data.homepage    = pom.homepage
  #    data.resources   = pom.resources
  #    data.mailinglist = pom.resources.mailinglist
  #    data.development = pom.resources.development
  #    data.forum       = pom.forum
  #    data.wiki        = pom.wiki
  #    data.blog        = pom.blog
  #    data.copyright   = pom.copyright
  #  rescue LoadError
  #    if file = Dir[path_base + '*.gemspec'].first
  #      gem = YAML.load(file)
  #      data.title       = gem.title
  #      data.version     = gem.version
  #      data.subtitle    = nil
  #      date.homepage    = gem.homepage
  #      data.mailinglist = gem.email
  #      data.development = nil
  #      data.forum       = nil
  #      data.wiki        = nil
  #      data.blog        = nil
  #      data.copyright   = nil
  #    else
  #      puts "No Metadata!"
  #      # TODO: we may be able to develop some other hueristics here, but for now, nope.
  #    end
  #  end
  #  return data
  #end

  end

end
