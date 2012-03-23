# encoding: UTF-8

require 'shomen/metadata'
require 'shomen/model'

module Shomen

  # TODO: Use a shared Adapter base class.

  # This adapter is used to convert YARD's documentation extracted
  # from a local store (`.yardoc`) to Shomen's pure-data format.
  #
  class YardAdaptor

    # New adaptor.
    def initialize(options)
      initialize_yard

      @store  = options[:store] || '.yardoc'
      @files  = options[:files] || ['lib', 'README*']
      @webcvs = options[:webcvs]
      @source = options[:source]
    end

    #
    def initialize_yard
      require 'yard'
    end

    # The hash object that is used to store the generated 
    # documentation.
    attr :table

    #
    attr :store

    #
    attr :files

    #
    attr :webcvs

    #
    attr :source

    #
    def source?
      @soruce
    end

    # Generate the shomen data structure.
    def generate
      if not File.exist?(store)
        $stderr.puts "ERROR: YARD database not found -- '#{store}`."
        exit -1
      end

      @table = {}

      scripts = []

      generate_metadata

      @registry = YARD::Registry.load!(store)
      @registry.each do |object|
        case object.type
        when :constant
          scripts.push(object.file)
          generate_constant(object)
        when :class, :module
          scripts.push(object.file)
          generate_class(object)
          # TODO: is this needed?
          #object.constants.each do |c|
          #  generate_constant(c)
          #end
        when :method
          scripts.push(object.file)
          generate_method(object)
        else
          $stderr.puts "What is an #{object.type}? Ignored!"
        end
      end

      # TODO: Are c/c++ sourse files working okay?
      # TODO: Add a generator for non-ruby script (e.g. .js)?
      collect_files.each do |file|
        case File.extname(file)
        when '.rb', '.rbx', '.c', '.cpp'
          generate_script(file)
        when '.rdoc', '.md', '.markdown', '.txt'
          generate_document(file)
        else
          generate_document(file)
        end
      end

      # TODO: Also pass parent ?
      scripts.uniq.each do |file|
        generate_script(file)
      end
    end

  private

    #
    def project_metadata
      @project_metadata ||= Shomen::Metadata.new
    end

    # Collect files given list of +globs+.
    def collect_files
      globs = @files
      globs = globs.map{ |glob| Dir[glob] }.flatten.uniq
      globs = globs.map do |glob|
        if File.directory?(glob)
          Dir[File.join(glob, '**/*')]
        else
          glob
        end
      end
      list = globs.flatten.uniq.compact
      list = list.reject{ |path| File.extname(path) == '.html' }
      list = list.select{ |path| File.file?(path) }
      list
    end

    # Generate project metadata entry.
    #
    # @return [Hash] metadata added to the documentation table
    def generate_metadata
      metadata = Metadata.new

      @table['(metadata)'] = metadata.to_h
    end

    # Generate a class or module structure.
    #
    # @note As to whether `methods` also contains the accessor methods
    #   listed in `accessors` is left to YARD to determine.
    #   
    # @return [Hash] class data that has been placed in the table
    def generate_class(yard_class)
      debug_msg(yard_class.path.to_s)

      meths = yard_class.meths(:included=>false, :inherited=>false)

      if yard_class.type == :class
        model = Model::Class.new
        model.superclass = yard_class.superclass ? yard_class.superclass.path : 'Object'
      else 
        model = Model::Module.new
      end

      model.path            = yard_class.path
      model.name            = yard_class.name.to_s
      model.namespace       = yard_class.namespace.path  #full_name.split('::')[0...-1].join('::'),
      model.comment         = yard_class.docstring.to_s
      model.format          = 'rdoc'  #TODO: how to determine? rdoc, markdown or plaintext ?
      model.constants       = yard_class.constants.map{ |x| x.path }  #TODO: complete_name(x.name, c.full_name) }
      model.includes        = yard_class.instance_mixins.map{ |x| x.path }
      model.extensions      = yard_class.class_mixins.map{ |x| x.path }
      model.modules         = yard_class.children.select{ |x| x.type == :module }.map{ |x| x.path }
                              #yard_class.modules.map{ |x| complete_name(x.name, c.full_name) }
      model.classes         = yard_class.children.select{ |x| x.type == :class }.map{ |x| x.path }
                              #yard_class.classes.map{ |x| complete_name(x.name, c.full_name) }

      model.methods         = meths.select.map{ |m| m.path }
      #model.methods         = meths.select{ |m| m.scope == :instance }.map{ |m| m.path }
      #model.class_methods   = meths.select{ |m| m.scope == :class }.map{ |m| m.path }

      model.accessors       = yard_class.attributes[:class].map{ |k, rw| yard_class.path + '.' + k.to_s } +
                              yard_class.attributes[:instance].map{ |k, rw| yard_class.path + '#' + k.to_s }
      #model.class_accessors = yard_class.attributes[:class].map{ |k, rw| yard_class.path + '.' + k.to_s }

      model.files           = yard_class.files.map{ |f, l| "/#{f}" } # :#{l}" }

      model.tags            = translate_tags(yard_class)

      #@files.concat(yard_class.files.map{ |f, l| f })

      @table[model.path] = model.to_h
    end

=begin
    # Generate a module structure.
    #
    def generate_module(object)
      index = object.path.to_s
      #meths = object.meths(:included=>false, :inherited=>false)

      debug_msg(index)

      data = Model::Module.new(Yard::ModuleAdapter.new(object)).to_h

      #data = Shomen::Model::Module.new(
      #  'name'          => object.name.to_s,
      #  'namespace'     => object.namespace.path, #full_name.split('::')[0...-1].join('::')
      #  'comment'       => object.docstring.to_s,
      #  'constants'     => object.constants.map{ |x| x.path }, #complete_name(x.name, c.full_name) }
      #  'includes'      => object.instance_mixins.map{ |x| x.path },
      #  'extensions'    => object.class_mixins.map{ |x| x.path },
      #  'modules'       => object.children.select{ |x| x.type == :module }.map{ |x| x.path }, 
      #                     #object.modules.map{ |x| complete_name(x.name, c.full_name) }
      #  'classes'       => object.children.select{ |x| x.type == :class }.map{ |x| x.path },
      #                     #object.classes.map{ |x| complete_name(x.name, c.full_name) }
      #  'methods'       => meths.select{ |m| m.scope == :instance }.map{ |m| m.path },
      #  'class-methods' => meths.select{ |m| m.scope == :class }.map{ |m| m.path },
      #  #'attributes'       => meths.select{ |m| m.scope == :instance }.map{ |m| m.path },
      #  #'class-attributes' => meths.select{ |m| m.scope == :class }.map{ |m| m.path },
      #  'files'         => object.files.map{ |f, l| "/#{f}:#{l}" }
      #).to_h

      #@files.concat(object.files.map{ |f, l| f })

      @table[index] = data
    end
=end

    # Generate a method structure.
    #
    def generate_method(yard_method)
      debug_msg(yard_method.to_s)

      # not sure what to do with methods with no signatures ?
      if !yard_method.signature
        debug_msg "no method signature -- #{yard_method.inspect}"
        return 
      end

      model = Model::Method.new
      #class_model = object.scope == :instance ? Shomen::Module::Method : Shomen::Model::Function

      model.path        = yard_method.path
      model.name        = yard_method.name.to_s
      model.namespace   = yard_method.parent.path  
      model.comment     = yard_method.docstring.to_s
      model.format      = 'rdoc'  # TODO: how to determine? rdoc, markdown or plain 
      model.aliases     = yard_method.aliases.map{ |a| a.path }  #method_name(a) }
      # TODO: how to get alias_for from YARD?
      #model.alias_for = method_name(yard_method.alias_for)
      model.singleton   = (yard_method.scope == :class)

      model.declarations << yard_method.scope.to_s
      model.declarations << yard_method.visibility.to_s
      # FIXME
      #model.declarations << yard_method.attr_info

      model.interfaces = []
      yard_method.tags.each do |tag|
        case tag
        when ::YARD::Tags::OverloadTag
          model.interfaces << parse_interface(tag)
        end
      end
      model.interfaces << parse_interface(yard_method)

      model.returns = (
        rtns = []
        yard_method.tags(:return).each do |tag|
          tag.types.each do |t|
            rtns << {'type'=>t, 'comment'=>tag.text}
          end
        end
        rtns
      )

      model.file     = '/'+yard_method.file
      model.line     = yard_method.line.to_i
      model.source   = yard_method.source.to_s.strip
      model.language = yard_method.source_type.to_s
      model.dynamic  = yard_method.dynamic

      model.tags     = translate_tags(yard_method)

      @table[model.path] = model.to_h
    end

    # Parse a yard method's interface.
    def parse_interface(yard_method)
      args, block = [], {}
      image, returns = yard_method.signature.split(/[=-]\>/)
      image = image.strip
      if i = image.index(/\)\s*\{/)
        block['image'] = image[i+1..-1].strip
        image          = image[0..i].strip
      end
      image = image.sub(/^def\s*/, '')
      image = image.sub(/^self\./, '')
      image = image.sub('( )','()')

      yard_method.parameters.each do |n,v|
        n = n.to_s
        case n
        when /^\&/
          block['name'] = n
        else
          args << (v ? {'name'=>n,'default'=>v} : {'name'=>n})
        end
      end

      result = {}
      result['signature']  = image
      result['arguments']  = args
      #result['parameters'] = params
      result['block']      = block unless block.empty?
      result['returns']    = returns.strip if returns
      result
    end
    private :parse_interface

    # Generate a constant.
    #
    def generate_constant(yard_constant)
      debug_msg(yard_constant.path.to_s)

      model = Model::Constant.new

      model.path      = yard_constant.path
      model.name      = yard_constant.name.to_s
      model.namespace = yard_constant.namespace.path  
      model.comment   = yard_constant.docstring.to_s
      model.format    = 'rdoc'  #  TODO: how to determine? rdoc, markdown or plain 
      model.value     = yard_constant.value
      model.tags      = translate_tags(yard_constant)
      model.files     = yard_constant.files.map{|f,l| "/#{f}"}  # or "#{f}:#{l}" ?

      @table[model.path] = model.to_h
    end

    # Generate a file.
    #
    def generate_document(yard_document)
      debug_msg(yard_document)

      model = Model::Document.new

      # FIXME: make absolute
      absolute_path = yard_document.to_s

      model.path   = yard_document.to_s
      model.name   = File.basename(absolute_path)
      model.mtime  = File.mtime(absolute_path)
      model.text   = File.read(absolute_path)
      model.format = mime_type(absolute_path)

      @table['/'+model.path] = model.to_h
    end

    # Generate a script entry.
    #
    def generate_script(yard_script)
      debug_msg(yard_script)

      model = Model::Script.new

      # FIXME: make absolute
      absolute_path = yard_script.to_s

      model.path  = yard_script.to_s
      model.name  = File.basename(absolute_path)
      model.mtime = File.mtime(absolute_path)

      if source?
        model.source   = File.read(absolute_path) #file.comment
        model.language = mime_type(absolute_path)
      end

      webcvs = project_metadata['webcvs'] || webcvs
      if webcvs
        model.uri      = File.join(webcvs, model.path)
        model.language = mime_type(absolute_path)
      end

      #  model.header        = ""
      #  model.footer        = ""
      #  model.requires      =
      #  model.constants     =
      #  model.modules       =
      #  model.classes       =
      #  model.methods       =
      #  model.class_methods =

      @table['/'+model.path] = model.to_h

      #table[index] = Shomen::Model::Script.new(
      #  "name"        => File.basename(object),
      #  "path"        => object,
      #  #"loadpath"    => "lib",
      #  "mtime"       => File.mtime(object),
      #  "header"      => "",
      #  "footer"      => "",
      #  # "requires"    : ["fileutils"],
      #  # "constants"   : ["MusicStore::CONFIG_DIRECTORY"],
      #  # "modules"     : ["MusicStore", "MusicStore::MusicMixin"],
      #  # "classes"     : ["MusicStore::Song"],
      #  # "functions"   : ["MusicStore.config_directory"],
      #  # "methods"     : ["MusicStore::MusicMixin#play", "MusicStore::MusicMixin#artist"]
      #  "source"      => File.read(object)
      #).to_h

      @table['/'+model.path] = model.to_h
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

    # Given a file return offical mime-type basic on file extension.
    #
    # FIXME: official mime types?
    def mime_type(path)
      case File.extname(path)
      when '.rb', '.rbx'      then 'text/x-ruby'
      when '.c'               then 'text/c-source'  # x-c-code
      when '.js'              then 'text/ecmascript'
      when '.rdoc'            then 'text/rdoc'
      when '.md', '.markdown' then 'text/markdown'
      else 'text/plain'
      end
    end

    # Convert YARD Tags to simple Hash.
    #
    # TODO: Remove param tags?
    def translate_tags(yard_object)
      tags = {}
      yard_object.tags.each do |tag|
        next if tag.tag_name == 'return'
        tags[tag.tag_name] = tag.text
      end
      return tags
    end

  end

end


















=begin
    # Generate a method structure.
    #
    def generate_attribute(object)
      index = "#{object.path}"

      debug_msg(index)

      data = Model::Method.new(Yard::MethodAdapter.new(object)).to_h

      ##code       = m.source_code_raw
      ##file, line = m.source_code_location

      ##full_name = method_name(m)

      ##'prettyname'   => m.pretty_name,
      ##'type'         => m.type, # class or instance

      #args = []
      #object.parameters.each do |var, val|
      #  if val
      #    args << { 'name' => var, 'default'=>val }
      #  else
      #    args << { 'name' => var }
      #  end
      #end
      #
      #rtns = []
      #object.tags(:return).each do |t|
      #  t.types.each do |ty|
      #    rtns << { 'type' => ty, 'comment' => t.text }
      #  end
      #end
      #
      #table[index] = Shomen::Model::Attribute.new(
      #  'name'         => object.name.to_s,
      #  'namespace'    => object.parent.path,
      #  'comment'      => object.docstring.to_s,
      #  'access'       => object.visibility.to_s,
      #  'singleton'    => object.scope == :class,
      #  'aliases'      => object.aliases.map{ |a| a.path }, #method_name(a) },
      #  #'alias_for'    => method_name(m.is_alias_for),
      #  'interfaces'   => [{'interface'  => object.signature.sub('def ', ''), #m.params,
      #                      'arguments'  => args,
      #                      'parameters' => []
      #                      #'block'     => m.block_params, # TODO: what is block?
      #                    }],
      #  'returns'      => rtns,
      #  'file'         => "/#{object.file}",
      #  'line'         => object.line,
      #  'source'       => object.source,
      #  'language'     => object.source_type.to_s,
      #  'dynamic'      => object.dynamic
      #).to_h

      @table[index] = model.to_h
    end
=end

