#require 'shomen/components/abstract'
require 'ostruct'

module Shomen

  # Metadata mixin, needs #path_base.
  #
  module Metadata

    #
    def metadata
      @metadata ||= get_metadata
    end

    # TODO: Need a better way to determine if POM::Metadata exists.
    def get_metadata
      data = OpenStruct.new
      begin
        require 'pom/metadata'
        pom = POM::Metadata.new(path_base)
        raise LoadError unless pom.name
        data.title       = pom.title
        data.version     = pom.version
        data.subtitle    = nil #pom.subtitle
        data.homepage    = pom.homepage
        data.resources   = pom.resources
        data.mailinglist = pom.resources.mailinglist
        data.development = pom.resources.development
        data.forum       = pom.forum
        data.wiki        = pom.wiki
        data.blog        = pom.blog
        data.copyright   = pom.copyright
      rescue LoadError
        if file = Dir[path_base + '*.gemspec'].first
          gem = YAML.load(file)
          data.title       = gem.title
          data.version     = gem.version
          data.subtitle    = nil
          date.homepage    = gem.homepage
          data.mailinglist = gem.email
          data.development = nil
          data.forum       = nil
          data.wiki        = nil
          data.blog        = nil
          data.copyright   = nil
        else
          puts "No Metadata!"
          # TODO: we may be able to develop some other hueristics here, but for now, nope.
        end
      end
      return data
    end

    #
    def scm
      Dir[File.join(path_base.to_s,"{.svn,.git}")].first
    end

  end

end

