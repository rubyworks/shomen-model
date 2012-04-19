# encoding: UTF-8

require 'shomen/metadata'
require 'shomen/model'

module Shomen

  # This adapter is used to convert RDoc's documentation extracted
  # from a local store (`.rdoc`) to Shomen's pure-data format.
  #
  # There's a bit of a limitation with adding scripts to the Shomen
  # table, as it appears rdoc only keeps track of script files for methods.
  # So any file thet doesn't contain at least one method definition won't
  # show up. We'll see if we can fix this in a future version.
  #
  # In addition, documentation files are not tracked at all, so they have
  # to provided on the command line regardless --though by default any
  # README file will be included.
  #
  # WARNING: RDoc's RI::Store has some issues and presently some information
  # is not accessible that otherwise would be included. B/c of this we recommend
  # using the traditional `rdoc-shomen` generator instead until these issues
  # are resolved.
  #
  class RDocAdaptor

    # Initialize new RDoc adaptor.
    def initialize(options)
      initialize_rdoc

      @store  = options[:store] || '.rdoc'
      @files  = options[:files] || ['README*']  #['lib', 'README*']
      @webcvs = options[:webcvs]
      @source = options[:source]
    end

    # Load RDoc library. Must be RDoc v3 or greater. We invoke the `gem` method
    # in this method in order to ensure we are not using the rdoc library included
    # with the Ruby distribution, which is out of date.
    #
    # Returns nothing.
    def initialize_rdoc
      gem 'rdoc', '>3'  # rescue nil

      require 'rdoc'
      #require 'rdoc/ri'
      #require 'rdoc/markup'
      require 'shomen/rdoc/extensions'
    end

    # The hash object that is used to store the generated 
    # documentation.
    #
    # Returns documentation table. [Hash]
    attr :table

    # Location to of RDoc documentation cache. This defaults to `.rdoc` which is
    # where RDoc normally places it's generated documentation files.
    #
    # Returns String path to RDoc documentation cache.
    attr :store

    # Files to be documented.
    #
    # Returns Array of file paths.
    attr :files

    # URI prefix which can be used to link to online documentation.
    #
    # Returns String.
    attr :webcvs

    # Include source code in scripts?
    #
    # Returns true/false.
    attr :source

    # Include source code in scripts?
    #
    # Returns true/false.
    def source?
      @soruce
    end

    # Generate the shomen data structure.
    #
    # Returns Hash of documentation table.
    def generate
      if not File.exist?(store)
        $stderr.puts "ERROR: RDoc store not found -- '#{store}`."
        exit -1
      end

      @table = {}

      constants = []
      scripts   = []

      db = ::RDoc::RI::Store.new(store)
      db.load_cache

      generate_metadata

      debug_msg "Generating class/module documentation:"
      db.modules.each do |name|
        object = db.load_class(name)
        constants.concat(object.constants)
        generate_class(object)
      end

      debug_msg "Generating class method documentation:"
      db.class_methods.each do |module_name, methods|
        methods.each do |name|
          object = db.load_method(module_name, name)
          scripts.push(object.file)
          generate_method(object)
        end
      end

      debug_msg "Generating instance method documentation:"
      db.instance_methods.each do |module_name, methods|
        methods.each do |name|
          object = db.load_method(module_name, "##{name}")
          scripts.push(object.file)
          generate_method(object)
        end
      end

      #debug_msg "Generating attribute method documentation:"
      #db.attributes.each do |module_name, methods|
      #  methods.each do |name|
      #    object = db.load_method(module_name, "##{name}")
      #    generate_method(object)
      #  end
      #end

      debug_msg "Generating constant documentation:"
      constants.each do |object|
        generate_constant(object)
      end

      debug_msg "Generating file documentation:"
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

      debug_msg "Generating script documentation:"
      scripts.each do |object|
        generate_script(object)
      end

      return @table
    end

  private

    # Project metadata.
    #
    # Returns Metadata instance.
    def project_metadata
      @project_metadata ||= Shomen::Metadata.new
    end

    # Collect files given list of +globs+.
    #
    # Returns Array of files.
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
    # Returns Hash of metadata, as added to the documentation table
    def generate_metadata
      #project_metadata = Metadata.new
      @table['(metadata)'] = project_metadata.to_h
    end

    # Add constant to table.
    #
    # rdoc_constant - RDoc constant documentation object.
    #
    # Returns Hash for constant documentation entry.
    def generate_constant(rdoc_constant)
      debug_msg "  #{rdoc_constant.name}"

      model = Shomen::Model::Constant.new

      model.path      = rdoc_constant.parent.full_name + '::' + rdoc_constant.name
      model.name      = rdoc_constant.name
      model.namespace = rdoc_constant.parent.full_name
      model.comment   = comment(rdoc_constant.comment)
      model.format    = 'rdoc'  # or tomdoc ?
      model.value     = rdoc_constant.value
      model.files     = ["/#{rdoc_constant.file.full_name}"]

      @table[model.path] = model.to_h
    end

    # Add classes (and modules) to table.
    #
    # rdoc_class - RDoc class documentation object.
    #
    # Returns Hash of class or module documentation entry.
    def generate_class(rdoc_class)
      debug_msg "  %s" % [ rdoc_class.full_name ]

      if rdoc_class.type=='class'
        model = Shomen::Model::Class.new
      else
        model = Shomen::Model::Module.new
      end

      modules = (rdoc_class.modules_hash || {}).values
      classes = (rdoc_class.classes_hash || {}).values

      model.path             = rdoc_class.full_name
      model.name             = rdoc_class.name
      model.namespace        = rdoc_class.full_name.split('::')[0...-1].join('::')
      model.includes         = rdoc_class.includes.map{ |x| x.name }  # FIXME: How to "lookup" full name?
      model.extensions       = []                                     # TODO:  How to get extensions?
      model.comment          = comment(rdoc_class.comment)
      model.format           = 'rdoc'  # or tomdoc ?
      model.constants        = rdoc_class.constants.map{ |x| complete_name(x.name, rdoc_class.full_name) }

      model.modules          = modules.map{ |x| complete_name(x.name, rdoc_class.full_name) }
      model.classes          = classes.map{ |x| complete_name(x.name, rdoc_class.full_name) }

      model.methods          = rdoc_class.method_list.map{ |m| method_name(m) }.uniq
      model.accessors        = rdoc_class.attributes.map{ |a| method_name(a) }.uniq  #+ ":#{a.rw}" }.uniq

      model.files            = (rdoc_class.in_files || []).map{ |x| "/#{x.full_name}" }

      if rdoc_class.file
        model.files.unshift("/#{rdoc_class.file.full_name}")
      end

      if rdoc_class.type == 'class'
        # HACK: No idea why RDoc is returning some weird superclass:
        #   <RDoc::NormalClass:0xd924d4 class Object < BasicObject includes: []
        #     attributes: [] methods: [#<RDoc::AnyMethod:0xd92b8c Object#fileutils
        #     (public)>] aliases: []>
        # Maybe it has something to do with #fileutils?
        model.superclass = (
          case rdoc_class.superclass
          when nil
          when String
            rdoc_class.superclass
          else
            rdoc_class.superclass.full_name
          end
        )
      end

      @table[model.path] = model.to_h
    end

    # TODO: How to get literal interface separate from call-sequences?

    # Transform RDoc method to Shomen model and add to table.
    #
    # rdoc_method - RDoc method documentation object.
    #
    # Returns Hash of method documentation entry.
    def generate_method(rdoc_method)
      #list = methods_all + attributes_all

      #debug_msg "%s" % [rdoc_method.full_name]

      #full_name  = method_name(m)
      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      model = Shomen::Model::Method.new

      model.path        = method_name(rdoc_method)
      model.name        = rdoc_method.name
      model.namespace   = rdoc_method.parent_name
      model.comment     = comment(rdoc_method.comment)
      model.format      = 'rdoc' # or tomdoc ?
      model.aliases     = (rdoc_method.aliases || []).map{ |a| method_name(a) }
      model.alias_for   = method_name(rdoc_method.is_alias_for)
      model.singleton   = rdoc_method.singleton

      model.declarations << rdoc_method.type.to_s #singleton ? 'class' : 'instance'
      model.declarations << rdoc_method.visibility.to_s

      model.interfaces = []
      if rdoc_method.call_seq
        rdoc_method.call_seq.split("\n").each do |cs|
          cs = cs.to_s.strip
          model.interfaces << parse_interface(cs) unless cs == ''
        end
      end
      model.interfaces << parse_interface("#{rdoc_method.name}#{rdoc_method.params}")

      model.returns    = []  # RDoc doesn't support specifying return values
      model.file       = '/' + rdoc_method.file_name
      model.line       = rdoc_method.line.to_i  # FIXME: why is this always zero?
      model.source     = rdoc_method.source_code_raw

      if rdoc_method.respond_to?(:c_function)
        model.language = rdoc_method.c_function ? 'c' : 'ruby'
      else
        model.language = 'ruby'
      end

      @table[model.path] = model.to_h
    end

    # TODO: remove any trailing comment from interface

    # Parse method interface.
    #
    # interface - String representation of method interface.
    #
    # Returns Hash entry of method interface.
    def parse_interface(interface)
      args, block = [], {}

      interface, returns = interface.split(/[=-]\>/)
      interface = interface.strip
      if i = interface.index(/\)\s*\{/)
        block['image'] = interface[i+1..-1].strip
        interface = interface[0..i].strip
      end

      arguments = interface.strip.sub(/^.*?\(/,'').chomp(')')
      arguments = arguments.split(/\s*\,\s*/)
      arguments.each do |a|
        if a.start_with?('&')
          block['name'] = a
        else
          n,v = a.split('=')
          args << (v ? {'name'=>n,'default'=>v} : {'name'=>n})
        end
      end

      result = {}
      result['signature'] = interface
      result['arguments'] = args
      result['block']     = block unless block.empty?
      result['returns']   = returns.strip if returns
      return result
    end

    # Generate entries for information files, e.g. `README.rdoc`.
    #
    # rdoc_document - RDoc file documentation object.
    #
    # Returns Hash of document entry.
    def generate_document(rdoc_document)
      relative_path = (String === rdoc_document ? rdoc_document : rdoc_document.full_name)
      absolute_path = File.join(path_base, relative_path)

      model = Shomen::Model::Document.new

      model.path   = relative_path
      model.name   = File.basename(absolute_path)
      model.mtime  = File.mtime(absolute_path)
      model.text   = File.read(absolute_path) #file.comment
      model.format = mime_type(absolute_path)

      @table['/'+model.path] = model.to_h
    end

    # TODO: Add loadpath and make file path relative to it?

    # Generate script entries.
    #
    # rdoc_file - RDoc file documentation object.
    #
    # Returns Hash of script entry.
    def generate_script(rdoc_file)
      #debug_msg "Generating file documentation in #{path_output_relative}:"
      #templatefile = self.path_template + 'file.rhtml'

      debug_msg "%s" % [rdoc_file.full_name]

      absolute_path = File.join(path_base, rdoc_file.full_name)
      #rel_prefix  = self.path_output.relative_path_from(outfile.dirname)

      model = Shomen::Model::Script.new

      model.path      = rdoc_file.full_name
      model.name      = File.basename(rdoc_file.full_name)
      model.mtime     = File.mtime(absolute_path)

      # http://github.com/rubyworks/qed/blob/master/ lib/qed.rb

      if source?
        model.source   = File.read(absolute_path) #file.comment
        model.language = mime_type(absolute_path)
      end

      webcvs = project_metadata['webcvs'] || webcvs
      if webcvs
        model.uri      = File.join(webcvs, model.path)  # TODO: use open-uri ?
        model.language = mime_type(absolute_path)
      end

      #model.header   =
      #model.footer   =
      model.requires  = rdoc_file.requires.map{ |r| r.name }
      model.constants = rdoc_file.constants.map{ |c| c.full_name }

      # note that this utilizes the table we are building
      # so it needs to be the last thing done.
      @table.each do |k, h|
        case h['!']
        when 'module'
          model.modules ||= []
          model.modules << k if h['files'].include?(rdoc_file.full_name)
        when 'class'
          model.classes ||= []
          model.classes << k if h['files'].include?(rdoc_file.full_name)
        when 'method'
          model.methods ||= []
          model.methods << k if h['file'] == rdoc_file.full_name
        when 'class-method'
          model.class_methods ||= []
          model.class_methods << k if h['file'] == rdoc_file.full_name
        end
      end

      @table['/'+model.path] = model.to_h
    end

    # Get fully qualified name given +name+ and +namespace+.
    #
    # name      - String of name.
    # namespace - String of namespace.
    #
    # Returns String of fully qualified name.
    def complete_name(name, namespace)
      if name !~ /^#{namespace}/
        "#{namespace}::#{name}"
      else
        name
      end
    end

    # Get full method name.
    #
    # method - Method instance.
    #
    # Returns String of methods full name.
    def method_name(method)
      return nil if method.nil?
      if method.singleton
        i = method.full_name.rindex('::')     
        method.full_name[0...i] + '.' + method.full_name[i+2..-1]
      else
        method.full_name
      end
    end

    # Convert rdoc object comment into RDoc text.
    #
    # document - RDoc document object.
    #
    # Returns String of comment text.
    def comment(document)
      formatter = RDoc::Markup::ToRdoc.new
      text = document.accept(formatter)
      text.strip
    end

    # Determine mime-type by file extension. If a type can not be determined,
    # then returns `text/plain` type.
    #
    # path - String file path.
    #
    # Returns String of mime-type.
    def mime_type(path)
      case File.extname(path)
      when '.rb', '.rbx' then 'text/ruby'
      when '.c' then 'text/c-source'
      when '.rdoc' then 'text/rdoc'
      when '.md', '.markdown' then 'text/markdown'
      else 'text/plain'
      end
    end

    # Output progress information if rdoc debugging is enabled
    #
    # msg - String debug message.
    #
    # Returns nothing.
    def debug_msg(msg)
      return unless $DEBUG_RDOC
      case msg[-1,1]
        when '.' then tab = "= "
        when ':' then tab = "== "
        else          tab = "* "
      end
      $stderr.puts(tab + msg)
    end

    # Current working directory.
    #
    # Returns String of working directory.
    def path_base
      Dir.pwd
    end

  end

end




=begin

require 'fileutils'
require 'pathname'
require 'yaml'
require 'json'

require 'rdoc/rdoc'
require 'rdoc/generator'
require 'rdoc/generator/markup'

require 'shomen/metadata'
require 'shomen/model'  # TODO: have metadata in model
require 'shomen/rdoc/extensions'

# Shomen Adaptor for RDoc utilizes the rdoc tool to parse ruby source code
# to build a Shomen documenation file.
#
# RDoc is almost entirely a free-form documentation system, so it is not
# possible for Shomen to fully harness all the details it can support from
# the RDoc documentation, such as method argument descriptions.

class RDoc::Generator::Shomen

  # Register shomen generator with RDoc.
  RDoc::RDoc.add_generator(self)

  #include RDocShomen::Metadata

  # Standard generator factory method.
  def self.for(options)
    new(options)
  end

  # User options from the command line.
  attr :options

  # List of all classes and modules.
  #def all_classes_and_modules
  #  @all_classes_and_modules ||= RDoc::TopLevel.all_classes_and_modules
  #end

  # In the world of the RDoc Generators #classes is the same
  # as #all_classes_and_modules. Well, except that its sorted 
  # too. For classes sans modules, see #types.

  def classes
    @classes ||= RDoc::TopLevel.all_classes_and_modules.sort
  end

  # Only toplevel classes and modules.
  def classes_toplevel
    @classes_toplevel ||= classes.select {|klass| !(RDoc::ClassModule === klass.parent) }
  end

  #
  def files
    @files ||= (
      @files_rdoc.select{ |f| f.parser != RDoc::Parser::Simple }
    )
  end

  # List of toplevel files. RDoc supplies this via the #generate method.
  def files_toplevel
    @files_toplevel ||= (
      @files_rdoc.select{ |f| f.parser == RDoc::Parser::Simple }
    )
  end

  #

  def files_hash
    @files ||= RDoc::TopLevel.files_hash
  end

  # List of all methods in all classes and modules.
  def methods_all
    @methods_all ||= classes.map{ |m| m.method_list }.flatten.sort
  end

  # List of all attributes in all classes and modules.
  def attributes_all
    @attributes_all ||= classes.map{ |m| m.attributes }.flatten.sort
  end

  #
  def constants_all
    @constants_all ||= classes.map{ |c| c.constants }.flatten
  end

  ## TODO: What's this then?
  ##def json_creatable?
  ##  RDoc::TopLevel.json_creatable?
  ##end

  # RDoc needs this to function.
  def class_dir ; nil ; end

  # RDoc needs this to function.
  def file_dir  ; nil ; end

  # TODO: Rename ?
  def shomen
    @table || {}
  end

  # Build the initial indices and output objects
  # based on an array of top level objects containing
  # the extracted information.
  def generate(files)
    @files_rdoc = files.sort

    @table = {}

    generate_metadata
    generate_constants
    generate_classes
    #generate_attributes
    generate_methods
    generate_documents
    generate_scripts   # must be last b/c it depends on the others

    # TODO: method accessor fields need to be handled

    # THINK: Internal referencing model, YAML and JSYNC ?
    #ref_table = reference_table(@table)

  #rescue StandardError => err
  #  debug_msg "%s: %s\n  %s" % [ err.class.name, err.message, err.backtrace.join("\n  ") ]
  #  raise err
  end


protected

  #
  def initialize(options)
    @options = options
    #@options.diagram = false  # why?

    @path_base   = Pathname.pwd.expand_path

    # TODO: This is probably not needed any more.
    @path_output = Pathname.new(@options.op_dir).expand_path(@path_base)
  end

  # Current pathname.
  attr :path_base

  # The output path.
  attr :path_output

  #
  def path_output_relative(path=nil)
    if path
      path.to_s.sub(path_base.to_s+'/', '')
    else
      @path_output_relative ||= path_output.to_s.sub(path_base.to_s+'/', '')
    end
  end

  #
  def collect_methods(class_module, singleton=false)
    list = []
    class_module.method_list.each do |m|
      next if singleton ^ m.singleton
      list << method_name(m)
    end
    list.uniq
  end

  #
  def collect_attributes(class_module, singleton=false)
    list = []
    class_module.attributes.each do |a|
      next if singleton ^ a.singleton
      #p a.rw
      #case a.rw
      #when :write, 'W'
      #  list << "#{method_name(a)}="
      #else
        list << method_name(a)
      #end
    end
    list.uniq
  end

=end



#--
=begin
  #
  def generate_attributes
#$stderr.puts "HERE!"
#$stderr.puts attributes_all.inspect
#exit
    debug_msg "Generating attributes documentation:"
    attributes_all.each do |rdoc_attribute|
      debug_msg "%s" % [rdoc_attribute.full_name]

      adapter = Shomen::RDoc::MethodAdapter.new(rdoc_attribute)
      data    = Shomen::Model::Method.new(adapter).to_h

      @table[data['path']] = data

      #code       = m.source_code_raw
      #file, line = m.source_code_location

      #full_name = method_name(m)

      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      #model_class = m.singleton ? Shomen::Model::Function : Shomen::Model::Method
      #model_class = Shomen::Model::Attribute

      #@table[full_name] = model_class.new(
      #  'path'         => full_name,
      #  'name'         => m.name,
      #  'namespace'    => m.parent_name,
      #  'comment'      => m.comment.text,
      #  'access'       => m.visibility.to_s,
      #  'rw'           => m.rw,  # TODO: better name ?
      #  'singleton'    => m.singleton,
      #  'aliases'      => m.aliases.map{ |a| method_name(a) },
      #  'alias_for'    => method_name(m.is_alias_for),
      #  'image'        => m.params,
      #  'arguments'    => [],
      #  'parameters'   => [],
      #  'block'        => m.block_params, # TODO: what is block?
      #  'interface'    => m.arglists,
      #  'returns'      => [],
      #  'file'         => file,
      #  'line'         => line,
      #  'source'       => code
      #).to_h
    end
  end
=end
#++


#--
=begin
  #
  # N O T  U S E D
  #

  # Sort based on how often the top level namespace occurs, and then on the
  # name of the module -- this works for projects that put their stuff into
  # a namespace, of course, but doesn't hurt if they don't.
  def sort_salient(classes)
    nscounts = classes.inject({}) do |counthash, klass|
      top_level = klass.full_name.gsub( /::.*/, '' )
      counthash[top_level] ||= 0
      counthash[top_level] += 1
      counthash
    endfiles_toplevel
    classes.sort_by{ |klass|
      top_level = klass.full_name.gsub( /::.*/, '' )
      [nscounts[top_level] * -1, klass.full_name]
    }.select{ |klass|
      klass.document_self
    }
  end
=end

=begin
  # Loop through table and convert all named references into bonofied object
  # references.
  def reference_table(table)
    debug_msg "== Generating Reference Table"
    new_table = {}
    table.each do |key, entry|
      debug_msg "%s" % [key]
      data = entry.dup
      new_table[key] = data
      case data['!']
      when 'script'
        data["constants"]  = ref_list(data["constants"])
        data["modules"]    = ref_list(data["modules"])
        data["classes"]    = ref_list(data["classes"])
        data["functions"]  = ref_list(data["functions"])
        data["methods"]    = ref_list(data["methods"])
      when 'file'
      when 'constant'
        data["namespace"]  = ref_item(data["namespace"])
      when 'module', 'class'
        data["namespace"]  = ref_item(data["namespace"])
        data["includes"]   = ref_list(data["includes"])
        #data["extended"]  = ref_list(data["extended"])
        data["constants"]  = ref_list(data["constants"])
        data["modules"]    = ref_list(data["modules"])
        data["classes"]    = ref_list(data["classes"])
        data["functions"]  = ref_list(data["functions"])
        data["methods"]    = ref_list(data["methods"])
        data["files"]      = ref_list(data["files"])
        data["superclass"] = ref_item(data["superclass"]) if data.key?("superclass")
      when 'method', 'function'
        data["namespace"]  = ref_item(data["namespace"])
        data["file"]       = ref_item(data["file"])
      end
    end
    new_table
  end

  # Given a key, return the matching table item. If not found return the key.
  def ref_item(key)
    @table[key] || key
  end

  # Given a list of keys, return the matching table items.
  def ref_list(keys)
    #keys.map{ |k| @table[k] || k }
    keys.map{ |k| @table[k] || nil }.compact
  end

=end
#++

