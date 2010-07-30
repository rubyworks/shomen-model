= Showmen Documentation Specification

== Description

Showmen defines a standarard documentation model for Ruby programs.
The specification is a flat mapping that can either by saved in
YAML or JSYNC format.

== Why?

By using this standard, documentation parsing systesm have a single output
target format to worry about. And documentation template systems have single
standard input specificaton to use to generate output regardless of the 
documentation parsing that was used.

== Design By Example

We will use the following script, which would be located at 'lib/musicstore/song.rb'
in a project, as an example to elucidate the specification.

  # song.rb (c) 2010 John Doe

  # Toplevel namespace for my MusicStore application.
  module MusicStore

    # Where to store music store's configuration.
    CONFIG_DIRECTORY = "~/.config/musicstore"

    # Overridable setting for configuration directory.
    def self.config_directory
      @@config_directory ||= CONFIG_DIRECTORY
    end

    # Common methods for MusicStore classes.
    module MusicMixin
    end

    # This is the Song class.
    class Song
      include MusicMixin

      # Returns a String of the artists name.
      def artist    
      end

      # Play the song.
      # 
      # seconds - number of seconds to playback
      #
      # Returns Integer of forked process id.
      def play(seconds=nil)
      end

    end

  end


== Script Type

The +script+ type provides information about a ruby script _file_.

  "/musicstore/song.rb": {
      "!": "script",
      "name": "song.rb",
      "path": "musicstore",
      "header": "song.rb (c) 2010 John Doe",
      "footer": "",
      "constants": [],
      "modules": ["MusicStore"],
      "classes": [],
      "functions": [],
      "methods": []
  }

== Module Type

The +module+ type describes a Ruby Module.

  "MusicStore": {
      "!": "module",
      "name": "MusicStore",
      "namespace": "",
      "includes": [],
      "extended": [],
      "comment": "Common methods for MusicStore classes.",
      "constants": ["CONFIG_DIRECTORY"],
      "modules": ["SongMixin"],
      "classes": ["Song"],
      "functions": [],
      "methods": []
  }

== Class Type

The +class+ type describes a Ruby Class.

  "MusicStore::Song": {
      "!": "class",
      "name": "Song",
      "namespace": "MusicStore",
      "includes": ["SongMixin"],
      "extended": [],
      "comment": "This is the Song class.",
      "constants": [],
      "modules": [],
      "classes": [],
      "functions": [],
      "methods": ["artist", "play"]
  }

We left the +methods+ entry with an elipses as it would contain method-type
entries for each of it's two methods. An example of which you can see below.

== Constant Type

The +constant+ type describes a constant.

  "MusicStore::CONFIG_DIRECTORY": {
      "!": "constant",
      "name": "CONFIG_DIRECTORY",
      "namespace": "MusicStore"
      "comment": "Where to store music store's configuration."
  }

== Instance Method Type

The +method+ type describes an instance method.

  "MusicStore::Song#play": {
      "!": "method",
      "name": "play",
      "namespace": "MusicStore::Song",
      "comment": "Play the song.",
      "access": public
      "arguments": [
        {
          "name": "seconds",
          "comment": "number of seconds to playback"
        }
      ]
      "return": [
         {
           "type": "Integer",
           "comment": "forked process id"
         }
      ]
  }

== Functional Method Type

The +function+ type describes a class/module singleton method.

  "MusicStore::Song.config_directory": {
      "!": "function",
      "name": "config_directory",
      "namespace": "MusicStore",
      "comment": "Overridable setting for configuration directory.",
      "access": public
      "arguments": []
      "return": [
         {
           "type": "String",
           "comment": "confifuration directory"
         }
      ]
  }

