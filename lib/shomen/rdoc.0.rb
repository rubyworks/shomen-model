#begin
#  # requiroing rubygems is needed here b/c ruby comes with
#  # rdoc but it's not the latest version.
#  require 'rubygems'
#  #gem 'rdoc', '>= 2.4' unless ENV['RDOC_TEST'] or defined?($rdoc_rakefile)
#  gem "rdoc", ">= 2.4.2"
#rescue
#end

#if Gem.available? "json"
#  gem "json", ">= 1.1.3"
#else
#  gem "json_pure", ">= 1.1.3"
#end
#require 'json'

require 'fileutils'
require 'pp'
require 'pathname'
require 'yaml'
require 'json'

require 'rdoc/rdoc'
require 'rdoc/generator'
require 'rdoc/generator/markup'

require 'shomen/model'

require 'shomen/rdoc/extensions'
require 'shomen/rdoc/module'

#require 'shomen/metadata'

## TODO: Is this needed?
## TODO: options = { :verbose => $DEBUG_RDOC, :noop => $dryrun }
#def fileutils
#  $dryrun ? FileUtils::DryRun : FileUtils
#end

# Shomen Adaptor for RDoc
#
# Of course RDoc is almost entirely a free-form documentation system,
# so it is not possible for Shomen to fully harness all the details it
# can support from the RDoc documentation.
#
# NOTE: This is probably slightly out of date with the current spec.

class RDoc::Generator::Shomen

  # Register shomen generator with RDoc.
  RDoc::RDoc.add_generator(self)

  # Base of file name used to save output.
  #FILENAME = "shomen"

  #include RDocShomen::Metadata

  #PATH = Pathname.new(File.dirname(__FILE__))

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

  ## Documented classes and modules sorted by salience first, then by name.
  #def classes_salient
  #  @classes_salient ||= sort_salient(classes)
  #end

  #
  #def classes_hash
  #  @classes_hash ||= RDoc::TopLevel.modules_hash.merge(RDoc::TopLevel.classes_hash)
  #end

  #
  #def modules
  #  @modules ||= RDoc::TopLevel.modules.sort
  #end

  #
  #def modules_toplevel
  #  @modules_toplevel ||= modules.select {|klass| !(RDoc::ClassModule === klass.parent) }
  #end

  #
  #def modules_salient
  #  @modules_salient ||= sort_salient(modules)
  #end

  #
  #def modules_hash
  #  @modules_hash ||= RDoc::TopLevel.modules_hash
  #end

  #
  #def types
  #  @types ||= RDoc::TopLevel.classes.sort
  #end

  #
  #def types_toplevel
  #  @types_toplevel ||= types.select {|klass| !(RDoc::ClassModule === klass.parent) }
  #end

  #
  #def types_salient
  #  @types_salient ||= sort_salient(types)
  #end

  #
  #def types_hash
  #  @types_hash ||= RDoc::TopLevel.classes_hash
  #end

  #
  def files
    @files ||= RDoc::TopLevel.files
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

  ## TODO: What's this then?
  ##def json_creatable?
  ##  RDoc::TopLevel.json_creatable?
  ##end

  # RDoc needs this to function.
  def class_dir ; nil ; end

  # RDoc needs this to function.
  def file_dir  ; nil ; end

  #
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
    generate_attributes
    generate_methods
    generate_files
    generate_scripts   # must be last b/c it depends on the others

    #pp table if $DEBUG

    #file = File.join(path_output, FILENAME)

    #yaml = @table.to_yaml
    #File.open(file + '.yaml', 'w'){ |f| f << yaml }

    #json = JSON.generate(@table)
    #File.open(file + '.json', 'w'){ |f| f << json }

    # TODO: Internal referencing model, YAML and JSYNC ?

    #ref_table = reference_table(@table)
    #yaml = ref_table.to_yaml
    #File.open(FILENAME + '-ref.yaml', 'w'){ |f| f << yaml }

  #rescue StandardError => err
  #  debug_msg "%s: %s\n  %s" % [ err.class.name, err.message, err.backtrace.join("\n  ") ]
  #  raise err
  end

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
=end

  # Given a key, return the matching table item. If not found return the key.
  def ref_item(key)
    @table[key] || key
  end

  # Given a list of keys, return the matching table items.
  def ref_list(keys)
    #keys.map{ |k| @table[k] || k }
    keys.map{ |k| @table[k] || nil }.compact
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

protected

  #
  def initialize(options)
    @options = options
    #@options.diagram = false  # why?

    @path_base   = Pathname.pwd.expand_path
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
  def generate_metadata
    metadata = Shomen::Metadata.new
    @table['(metadata)'] = metadata.to_h
  end

  # Add constants to table.
  def generate_constants
    debug_msg "Generating constant documentation:"
    classes.each do |base|
      base.constants.each do |rdoc_constant|
        adapter = Shomen::RDoc::ConstantAdapter.new(rdoc_constant)
        data    = Shomen::Model::Constant.new(adapter).to_h

        #full_name = "#{base.full_name}::#{c.name}"
        #debug_msg "%s" % [full_name]
        #@table[full_name] = Shomen::Model::Constant.new(
        #  "key"       => full_name,
        #  "name"      => c.name,
        #  "namespace" => "#{base.full_name}",
        #  "comment"   => c.comment, # description
        #  "value"     => c.value
        #).to_h

        @table[data['path']] = data
      end
    end
    return table     
  end

  # Add classes (and modules) to table.
  def generate_classes(table)
    debug_msg "Generating class/module documentation:"
    classes.each do |rdoc_class|
      debug_msg "%s (%s)" % [ rdoc_class.full_name, rdoc_class.path ]

      #outfile    = self.path_output + klass.path
      #rel_prefix = self.path_output.relative_path_from(outfile.dirname)
      #debug_msg "rendering #{path_output_relative(outfile)}"
      #self.render_template(templatefile, outfile, :klass=>klass, :rel_prefix=>rel_prefix)

      if c.type=='class'
        adapter = Shomen::RDoc::ClassAdapter.new(rdoc_class)
        data    = Shomen::Model::Class.new(adapter).to_h
      else
        adapter = Shomen::RDoc::ModuleAdapter.new(rdoc_class)
        data    = Shomen::Model::Module.new(adapter).to_h
      end

=begin
      # HACK: No idea why RDoc is returning some weird superclass:
      #   <RDoc::NormalClass:0xd924d4 class Object < BasicObject includes: []
      #     attributes: [] methods: [#<RDoc::AnyMethod:0xd92b8c Object#fileutils
      #     (public)>] aliases: []>
      # Maybe it has something to do with #fileutils?
      if c.type == 'class'
        superclass = (String === c.superclass ? c.superclass.to_s : c.superclass.name)
      else
        superclass = nil
      end

      model = model_class.new(
        "key"              => c.full_name,
        "name"             => c.name,
        "namespace"        => c.full_name.split('::')[0...-1].join('::'),
        "includes"         => c.includes.map{ |x| x.name },  # FIXME: How to "lookup" full name?
        #"extensions"       => []  # TODO: how?
        "comment"          => c.comment,
        "constants"        => c.constants.map{ |x| complete_name(x.name, c.full_name) },
        "modules"          => c.modules.map{ |x| complete_name(x.name, c.full_name) },
        "classes"          => c.classes.map{ |x| complete_name(x.name, c.full_name) },
        "methods"          => collect_methods(c, false),
        "class_methods"    => collect_methods(c, true),
        "attributes"       => collect_attributes(c, false),
        "class_attributes" => collect_attributes(c, true),
        "files"            => c.in_files.map{ |x| x.full_name }
      )
      if c.type == 'class'
        model["superclass"] = superclass || 'Object'
      end
=end

      @table[data['path']] = data
    end
    return table
  end

  # Returns String of fully qualified name.
  def complete_name(name, namespace)
    if name !~ /^#{namespace}/
      "#{namespace}::#{name}"
    else
      name
    end
  end

  #
  def generate_attributes(table)
    debug_msg "Generating attributes documentation:"
    attributes_all.each do |m|
      debug_msg "%s" % [m.full_name]

      code       = m.source_code_raw
      file, line = m.source_code_locationModel::Method

      full_name = method_name(m)

      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      #model_class = m.singleton ? Shomen::Model::Function : Shomen::Model::Method
      model_class = Shomen::Model::Attribute

      table[full_name] = model_class.new(
        'key'          => full_name,
        'name'         => m.name,
        'namespace'    => m.parent_name,
        'comment'      => m.comment,
        'access'       => m.visibility.to_s,
        'rw'           => m.rw,  # TODO: better name ?
        'singleton'    => m.singleton,
        'aliases'      => m.aliases.map{ |a| method_name(a) },
        'alias_for'    => method_name(m.is_alias_for),
        'image'        => m.params,
        'arguments'    => [],
        'parameters'   => [],
        'block'        => m.block_params, # TODO: what is block?
        'interface'    => m.arglists,
        'returns'      => [],
        'file'         => file,
        'line'         => line,
        'source'       => code
      ).to_h
    end
    return table
  end

  # Transform RDoc methods to Shomen model and add to table.
  def generate_methods(table)
    debug_msg "Generating method documentation:"

    methods_all.each do |rdoc_method|
      debug_msg "%s" % [rdoc_method.full_name]

      #code       = m.source_code_raw
      #file, line = m.source_code_location

      #full_name  = method_name(m)

      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      #model_class = m.singleton ? Shomen::Model::Function : Shomen::Model::Method
      #model_class = Shomen::Model::Method

      adapter = Shomen::RDoc::MethodAdapter.new(rdoc_method)
      data    = Shomen::Model::Method.new().to_h

      @table[data['path']] = data

      #table[full_name] = model_class.new(
      #  'key'          => full_name,
      #  'name'         => m.name,
      #  'namespace'    => m.parent_name,
      #  'comment'      => m.comment,
      #  'access'       => m.visibility.to_s,
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

  # Generate a documentation file for each file.
  #--
  # TODO: Add loadpath and make file path relative to it?
  #++
  def generate_scripts(table)
    debug_msg "Generating file documentation in #{path_output_relative}:"
    #templatefile = self.path_template + 'file.rhtml'

    files.each do |file|
      debug_msg "%s" % [file.full_name]

      abspath = File.join(path_base, file.full_name)

      #rel_prefix  = self.path_output.relative_path_from(outfile.dirname)
      #context     = binding()
      #debug_msg "rendering #{path_output_relative(outfile)}"

      modules = table.select { |k, h|
        h['!'] == 'module' && h['files'].include?(file.full_name)
      }.map{ |k, h| k }

      classes = table.select { |k, h|
        h['!'] == 'class' && h['files'].include?(file.full_name)
      }.map{ |k, h| k }

      methods = table.select { |k, h|
        h['!'] == 'method' && h['file'] == file.full_name
      }.map{ |k, h| k }

      class_methods = table.select { |k, h|
        h['!'] == 'class-method' && h['file'] == file.full_name
      }.map{ |k, h| k }

      adapter = Shomen::RDoc::ScriptAdapter.new(adapter)
      data    = Shomen::Model::Script.new(adapter).to_h

      data['methods']       = methods
      data['class-methods'] = class_methods
      data['classes']       = classes
      data['modules']       = modules

      @table['/'+data['path']] = data

      #Shomen::Model::Script.new(
      #  "key"            => file.full_name,
      #  "name"           => File.basename(file.full_name),
      #  "parent"         => File.dirname(file.full_name),
      #  "path"           => file.full_name,
      #  "mtime"          => File.mtime(abspath),
      #  "header"         => "", # TODO
      #  "footer"         => "", # TODO
      #  "requires"       => file.requires.map{ |r| r.name },
      #  "constants"      => file.constants.map{ |c| c.full_name },
      #  "modules"        => modules,   #file.modules.map{ |x| x.name },
      #  "classes"        => classes,   #file.classes.map{ |x| x.name },
      #  "class-methods"  => functions, #collect_methods(file, true),
      #  "methods"        => methods,    #collect_methods(file, false)
      #  "source"         => File.read(abspath)
      #).to_h

      #self.render_template(templatefile, outfile, :file=>file, :rel_prefix=>rel_prefix)
    end
  end

  # Generate entries for whole information files, e.g. README files.
  def generate_files(table)
    files_toplevel.each do |rdoc_file|
      adapter = Shomen::RDoc::DocumentAdapter.new(rdoc_file)
      data    = Shomen::Model::Document.new(adapter).to_h

      @table['/'+data['path']] = data

      #abspath = File.join(path_base, file.full_name)
      #table[file.full_name] = Shomen::Model::Document.new(
      #  "key"    => file.full_name,
      #  "name"   => File.basename(file.full_name),
      #  "parent" => File.dirname(file.full_name),
      #  "path"   => file.full_name,
      #  "mtime"  => File.mtime(abspath),
      #  "text"   => File.read(abspath) #file.comment
      #).to_h
      #table['/'+file.full_name] = data
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

  #
  def method_name(method)
    return nil if method.nil?
    if method.singleton
      i = method.full_name.rindex('::')     
      method.full_name[0...i] + '.' + method.full_name[i+2..-1]
    else
      method.full_name
    end
  end

  # Output progress information if rdoc debugging is enabled

  def debug_msg(msg)
    return unless $DEBUG_RDOC
    case msg[-1,1]
      when '.' then tab = "= "
      when ':' then tab = "== "
      else          tab = "* "
    end
    $stderr.puts(tab + msg)
  end

end




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

