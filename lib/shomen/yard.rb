require 'yard'
require 'shomen/metadata'

module Shomen

  # Convert YARD raw documentation to Shomen.
  #
  class YardAdaptor

    # Dummy constant.
    DUMMY = "this is a test"

    # The hash object that is used to store the generated 
    # documentation.
    attr :table

    # New adaptor.
    def initialize(options)
      @clear    = options[:clear]
      @db       = options[:db]       || '.yardoc'
      @yardopts = options[:yardopts] || '.yardopts'
    end

    #
    def setup
      if @clear or not File.exist?(@db)
        `yard -n -b #{@db}`  # TODO: don't shell out
      end
      @registry = YARD::Registry.load!('.yardoc')
    end

    # Determine files by looking up .yardopts (kind of a hack).
    def files
      @files ||= (
        list = []
        File.read(@yardopts).split("\n").each do |line|
          line = line.strip
          next if line =~ /^-/
          line = File.join(line, '**/*') if File.directory?(line)
          list.concat(Dir[line])
        end
        list.reject!{ |path| File.extname(path) == '.html' }
        list.select!{ |path| File.file?(path) }
        list
      )
    end

    # Generate the shomen data structure.
    def generate
      setup

      #@files = []
      @table = {}

      generate_metadata

      @registry.each do |object|
        case object.type
        when :class
          generate_class(object)
# FIXME: where are the constants?
          object.constants.each do |c|
            generate_constant(c)
          end
        when :module
          generate_module(object)
          object.constants.each do |c|
            generate_constant(c)
          end
        when :method
          generate_method(object)
        when :constant  # TODO: does this even exit?
          generate_constant(object)
        else
          $stderr.puts "What is an #{object.type}? Ignored!"
        end
      end

      files.each do |file|
        case File.extname(file)
        when '.rb', '.rbx', '.js', '.html', '.css'
          generate_script(file)
        else
          generate_file(file)
        end
      end
    end

    #
    def generate_metadata
      metadata = Metadata.new
      #if File.exist?('.ruby')
      #  data = YAML.load_file('.ruby')
      #else
      #  data = {}
      #end
      @table['(metadata)'] = metadata.to_h
    end

    # Generate a class structure.
    #
    # @return [Hash] class data that has been placed in the table
    def generate_class(object)
      debug_msg index = object.path.to_s

      meths = object.meths(:included=>false, :inherited=>false)

      data = {}
      data["!"]          = 'class'
      data["name"]       = object.name.to_s
      data["namespace"]  = object.namespace.path #full_name.split('::')[0...-1].join('::')
      data["comment"]    = object.docstring.to_s
      #data["format"]     = 'rdoc',  /* markdown, text */  # TODO: how to determine?
      data["constants"]  = object.constants.map{ |x| x.path } #complete_name(x.name, c.full_name) }
      data["includes"]   = object.instance_mixins.map{ |x| x.path }
      data["extended"]   = object.class_mixins.map{ |x| x.path }
      data["modules"]    = object.children.select{ |x| x.type == :module }.map{ |x| x.path } #object.modules.map{ |x| complete_name(x.name, c.full_name) }
      data["classes"]    = object.children.select{ |x| x.type == :class }.map{ |x| x.path } #object.classes.map{ |x| complete_name(x.name, c.full_name) }
      data["functions"]  = meths.select{ |m| m.scope == :class }.map{ |m| m.path }
      data["methods"]    = meths.select{ |m| m.scope == :instance }.map{ |m| m.path }
      data["files"]      = object.files.map{ |f, l| "/#{f}:#{l}" }
      data["superclass"] = object.superclass ? object.superclass.path : 'Object'

      #@files.concat(object.files.map{ |f, l| f })

      @table[index] = data
    end

    # Generate a module structure.
    #
    def generate_module(object)
      debug_msg index = object.path.to_s

      meths = object.meths(:included=>false, :inherited=>false)

      data = {}
      data["!"]          = 'module'
      data["name"]       = object.name.to_s
      data["namespace"]  = object.namespace.path #full_name.split('::')[0...-1].join('::')
      data["comment"]    = object.docstring.to_s
      data["constants"]  = object.constants.map{ |x| x.path } #complete_name(x.name, c.full_name) }
      data["includes"]   = object.instance_mixins.map{ |x| x.path }
      data["extended"]   = object.class_mixins.map{ |x| x.path }
      data["modules"]    = object.children.select{ |x| x.type == :module }.map{ |x| x.path } #object.modules.map{ |x| complete_name(x.name, c.full_name) }
      data["classes"]    = object.children.select{ |x| x.type == :class }.map{ |x| x.path } #object.classes.map{ |x| complete_name(x.name, c.full_name) }
      data["functions"]  = meths.select{ |m| m.scope == :class }.map{ |m| m.path }
      data["methods"]    = meths.select{ |m| m.scope == :instance }.map{ |m| m.path }
      data["files"]      = object.files.map{ |f, l| "/#{f}:#{l}" }

      #@files.concat(object.files.map{ |f, l| f })

      @table[index] = data
    end

    # Generate a method structure.
    #
    def generate_method(object)
      debug_msg index = "#{object.path}"

      #code       = m.source_code_raw
      #file, line = m.source_code_location

      #full_name = method_name(m)

      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      args = []
      object.parameters.each do |var, val|
        if val
          args << { 'name' => var, 'default'=>val }
        else
          args << { 'name' => var }
        end
      end

      rtns = []
      object.tags(:return).each do |t|
        t.types.each do |ty|
          rtns << { 'type' => ty, 'comment' => t.text }
        end
      end

      table[index] = {
        '!'            => object.scope == :instance ? 'method' : 'function',
        'name'         => object.name.to_s,
        'parent'       => object.parent.path,
        'comment'      => object.docstring.to_s,
        'access'       => object.visibility.to_s,
        'singleton'    => object.scope == :class,
        'aliases'      => object.aliases.map{ |a| a.path }, #method_name(a) },
        #'alias_for'    => method_name(m.is_alias_for),
        'image'        => object.signature.sub('def ', ''), #m.params,
        'arguments'    => args,
        'parameters'   => [],
        #'block'        => m.block_params, # TODO: what is block?
        #'interface'    => object.arglists,
        'returns'      => rtns,
        'file'         => "/#{object.file}",
        'line'         => object.line,
        'source'       => object.source
      }
    end

    # Generate a constant.
    #
    def generate_constant(object)
      debug_msg index = "#{object.path}"   # "#{base.full_name}::#{c.name}"

puts index
puts "----------------------------------------------------------------"
puts
puts

      table[index] = {
        "!"         => "constant",
        "name"      => object.name.to_s,
        "namespace" => object.namespace.path,
        "comment"   => object.docstring.to_s,
        "value"     => object.value
      }
    end

    # Generate a file.
    #
    def generate_file(object)
      debug_msg index = "/#{object}"

      table[index] = {
        "!"         => "file",
        "name"      => File.basename(object),
        "path"      => object,
        "mtime"     => File.mtime(object),
        "text"      => File.read(object)
      }
    end

    def generate_script(object)
      debug_msg index = "/#{object}"  # e.g. "/musicstore/song.rb": {

      table[index] = {
        "!"           => "script",
        "name"        => File.basename(object),
        "path"        => object,
        #"loadpath"    => "lib",
        "mtime"       => File.mtime(object),
        "header"      => "",
        "footer"      => "",
        # "requires"    : ["fileutils"],
        # "constants"   : ["MusicStore::CONFIG_DIRECTORY"],
        # "modules"     : ["MusicStore", "MusicStore::MusicMixin"],
        # "classes"     : ["MusicStore::Song"],
        # "functions"   : ["MusicStore.config_directory"],
        # "methods"     : ["MusicStore::MusicMixin#play", "MusicStore::MusicMixin#artist"]
        "source"      => File.read(object)
      }
    end

    # Output progress information if debugging is enabled
    #
    def debug_msg(msg)
      return unless $DEBUG
      case msg[-1,1]
        when '.' then tab = "= "
        when ':' then tab = "== "
        else          tab = "* "
      end
      $stderr.puts(tab + msg)
    end

  end

end
