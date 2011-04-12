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

#require 'rdoc-shomen/metadata'

# TODO: options = { :verbose => $DEBUG_RDOC, :noop => $dryrun }
def fileutils
  $dryrun ? FileUtils::DryRun : FileUtils
end

#
class RDoc::Generator::Shomen

  # Register shomen generator with RDoc.
  RDoc::RDoc.add_generator self

  # Base of file name used to save output.
  FILENAME = "shomen"

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

  # In the world of the RDoc Generators #classes is the same as 
  # #all_classes_and_modules. Well, except that its sorted too.
  # For classes sans modules, see #types.

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

  ## TODO: What's this then?
  ##def json_creatable?
  ##  RDoc::TopLevel.json_creatable?
  ##end

  # RDoc needs this to function.
  def class_dir ; nil ; end

  # RDoc needs this to function.
  def file_dir  ; nil ; end

  # Build the initial indices and output objects
  # based on an array of top level objects containing
  # the extracted information.
  def generate(files)
    @files_rdoc = files.sort

    @table = {}

    generate_metadata(@table)
    generate_constants(@table)
    generate_classes(@table)
    generate_methods(@table)
    generate_scripts(@table)   # have to do this last b/c it depends on the others
    generate_files(@table)

    #pp table if $DEBUG

    #file = File.join(@path_output, 'rdoc.jsync')

    yaml = @table.to_yaml
    File.open(FILENAME + '.yaml', 'w'){ |f| f << yaml }

    json = JSON.generate(@table)
    File.open(FILENAME + '.json', 'w'){ |f| f << json }

    # TODO: Internal referencing model, YAML and JSYNC ?

    #ref_table = reference_table(@table)
    #yaml = ref_table.to_yaml
    #File.open(FILENAME + '-ref.yaml', 'w'){ |f| f << yaml }

  #rescue StandardError => err
  #  debug_msg "%s: %s\n  %s" % [ err.class.name, err.message, err.backtrace.join("\n  ") ]
  #  raise err
  end

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
        data["parent"]     = ref_item(data["parent"])
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
  def generate_metadata(table)
    begin
      require 'gemdo/project'
      generate_metadata_from_gemdo(table)
    rescue Exception
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
  def generate_metadata_from_gemdo(table)
    project = GemDo::Project.new
    table['(metadata)'] = {
      "!"           => "metadata",
      "name"        => project.name,
      "version"     => project.version,
      "title"       => project.title,
      "summary"     => project.metadata.summary,
      "description" => project.metadata.description,
      "contact"     => project.metadata.contact,
      "homepage"    => project.metadata.resources.home
    }
  end

  #
  def generate_metadata_from_gemspec(table)
    file = Dir['*.gemspec'].first
    spec = RubyGems::Specification.new(file)  #?
    table['(metadata)'] = {
      "!"           => "metadata",
      "name"        => spec.name,
      "title"       => spec.name.upcase,
      "version"     => spec.version.to_s,
      "summary"     => spec.summary,
      "description" => spec.description,
      "contact"     => spec.email,
      "homepage"    => spec.homepage
    }
  end

  #
  def generate_constants(table)
    debug_msg "Generating constant documentation:"
    classes.each do |base|
      base.constants.each do |c|
        full_name = "#{base.full_name}::#{c.name}"
        debug_msg "%s" % [full_name]
        table[full_name] = {
          "!"         => "constant",
          "name"      => c.name,
          "namespace" => "#{base.full_name}",
          "comment"   => c.comment, # description
          "value"     => c.value
        }
      end
    end
    return table     
  end

  # Generate a documentation file for each class
  def generate_classes(table)
    debug_msg "Generating class documentation:"

    classes.each do |c|
      debug_msg "%s (%s)" % [ c.full_name, c.path ]
      #outfile    = self.path_output + klass.path
      #rel_prefix = self.path_output.relative_path_from(outfile.dirname)
      #debug_msg "rendering #{path_output_relative(outfile)}"
      #self.render_template(templatefile, outfile, :klass=>klass, :rel_prefix=>rel_prefix)

      data = {}
      data["!"]          = (c.type == 'class' ? "class" : "module")
      data["name"]       = c.name
      data["namespace"]  = c.full_name.split('::')[0...-1].join('::')
      data["includes"]   = c.includes.map{ |x| x.name }
      #data["extended"]  = []  # TODO: how?
      data["comment"]    = c.comment
      data["constants"]  = c.constants.map{ |x| x.name }
      data["modules"]    = c.modules.map{ |x| x.name }
      data["classes"]    = c.classes.map{ |x| x.name }
      data["functions"]  = collect_methods(c, true)
      data["methods"]    = collect_methods(c, false)
      data["files"]      = c.in_files.map{ |x| x.full_name }
      data["superclass"] = c.superclass if c.type == 'class'

      table[c.full_name] = data
    end
    return table
  end

  #
  def generate_methods(table)
    debug_msg "Generating method documentation:"
    methods_all.each do |m|
      debug_msg "%s" % [m.full_name]

      code       = m.source_code_raw
      file, line = m.source_code_location

      full_name = method_name(m)

      #'prettyname'   => m.pretty_name,
      #'type'         => m.type, # class or instance

      table[full_name] = {
        '!'            => (m.singleton ? 'function' : 'method'),
        'name'         => m.name,
        'parent'       => m.parent_name,
        'comment'      => m.comment,
        'access'       => m.visibility.to_s,
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
      }
    end
    return table
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

      functions = table.select { |k, h|
        h['!'] == 'function' && h['file'] == file.full_name
      }.map{ |k, h| k }

      methods = table.select { |k, h|
        h['!'] == 'method' && h['file'] == file.full_name
      }.map{ |k, h| k }

      table[file.full_name] = {
        "!"          => "script",
        "name"       => File.basename(file.full_name),
        "path"       => File.dirname(file.full_name),
        "mtime"      => File.mtime(abspath),
        "header"     => "", # TODO
        "footer"     => "", # TODO
        "requires"   => file.requires.map{ |r| r.name },
        "constants"  => file.constants.map{ |c| c.full_name },
        "modules"    => modules,   #file.modules.map{ |x| x.name },
        "classes"    => classes,   #file.classes.map{ |x| x.name },
        "functions"  => functions, #collect_methods(file, true),
        "methods"    => methods    #collect_methods(file, false)
      }

      #self.render_template(templatefile, outfile, :file=>file, :rel_prefix=>rel_prefix)
    end
    return table
  end

  # Generate entries for whole information files, e.g. README files.
  def generate_files(table)
    files_toplevel.each do |file|
      abspath = File.join(path_base, file.full_name)
      table[file.full_name] = {
        "!"     => "file",
        "name"  => File.basename(file.full_name),
        "path"  => File.dirname(file.full_name),
        "mtime" => File.mtime(abspath),
        "text"  => File.read(abspath) #file.comment
      }
    end
  end

  #
  def collect_methods(class_module, singleton=false)
    list = []
    class_module.method_list.each do |m|
      next if singleton ^ m.singleton
      list << method_name(m)
    end
    class_module.attributes.each do |a|
      next if singleton ^ a.singleton
      #p a.rw
      case a.rw
      when :write
        list << "#{method_name(a)}="
      else
        list << method_name(a)
      end
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


  # Generate an index page
  def generate_index_file
    debug_msg "Generating index file in #@path_output"
    templatefile = @path_template + 'index.rhtml'

    template_src = templatefile.read

    template = ERB.new(template_src, nil, '<>')
    template.filename = templatefile.to_s
    context = binding()

    output = nil

    begin
      output = template.result(context)
    rescue NoMethodError => err
      raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
        templatefile,
        err.message,
        eval( "_erbout[-50,50]", context )
      ], err.backtrace
    end

    outfile = path_base + @options.op_dir + 'index.html'
    unless $dryrun
      debug_msg "Outputting to %s" % [outfile.expand_path]
      outfile.open( 'w', 0644 ) do |fh|
        fh.print( output )
      end
    else
      debug_msg "Would have output to %s" % [outfile.expand_path]
    end
  end
=end

=begin
    # Load and render the erb template in the given +templatefile+ within the
    # specified +context+ (a Binding object) and write it out to +outfile+.
    # Both +templatefile+ and +outfile+ should be Pathname-like objects.

    def render_template(templatefile, outfile, local_assigns)
      output = erb_template.render(templatefile, local_assigns)

      #output = eval_template(templatefile, context)

      # TODO: delete this dirty hack when documentation for example for GeneratorMethods will not be cutted off by <script> tag
      begin
        if output.respond_to? :force_encoding
          encoding = output.encoding
          output = output.force_encoding('ASCII-8BIT').gsub('<script>', '&lt;script;&gt;').force_encoding(encoding)
        else
          output = output.gsub('<script>', '&lt;script&gt;')
        end
      rescue Exception => e
      end

      unless $dryrun
        outfile.dirname.mkpath
        outfile.open( 'w', 0644 ) do |file|
          file.print( output )
        end
      else
        debug_msg "would have written %d bytes to %s" %
        [ output.length, outfile ]
      end
    end
=end

=begin
    # Load and render the erb template in the given +templatefile+ within the
    # specified +context+ (a Binding object) and return output
    # Both +templatefile+ and +outfile+ should be Pathname-like objects.

    def eval_template(templatefile, context)
      template_src = templatefile.read
      template = ERB.new(template_src, nil, '<>')
      template.filename = templatefile.to_s

      begin
        template.result(context)
      rescue NoMethodError => err
        raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
          templatefile.to_s,
          err.message,
          eval("_erbout[-50,50]", context)
        ], err.backtrace
      end
    end
=end

#    #
#
#    def erb_template
#      @erb_template ||= Template.new(self, provisions)
#    end

=begin
  def render_template( templatefile, context, outfile )
    template_src = templatefile.read
    template = ERB.new( template_src, nil, '<>' )
    template.filename = templatefile.to_s

    output = begin
               template.result( context )
             rescue NoMethodError => err
               raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
                 templatefile.to_s,
                 err.message,
                 eval( "_erbout[-50,50]", context )
               ], err.backtrace
             end

    unless $dryrun
      outfile.dirname.mkpath
      outfile.open( 'w', 0644 ) do |ofh|
        ofh.print( output )
      end
    else
      debug_msg "  would have written %d bytes to %s" %
      [ output.length, outfile ]
    end
  end
=end

end


require "rdoc/parser/c"

# New RDoc somehow misses class comemnts.
# copyied this function from "2.2.2" 
if ['2.4.2', '2.4.3'].include? RDoc::VERSION
  class RDoc::Parser::C
    def find_class_comment(class_name, class_meth)
      comment = nil
      if @content =~ %r{((?>/\*.*?\*/\s+))
                     (static\s+)?void\s+Init_#{class_name}\s*(?:_\(\s*)?\(\s*(?:void\s*)\)}xmi then
        comment = $1
      elsif @content =~ %r{Document-(?:class|module):\s#{class_name}\s*?(?:<\s+[:,\w]+)?\n((?>.*?\*/))}m
        comment = $1
      else
        if @content =~ /rb_define_(class|module)/m then
          class_name = class_name.split("::").last
          comments = []
          @content.split(/(\/\*.*?\*\/)\s*?\n/m).each_with_index do |chunk, index|
            comments[index] = chunk
            if chunk =~ /rb_define_(class|module).*?"(#{class_name})"/m then
              comment = comments[index-1]
              break
            end
          end
        end
      end
      class_meth.comment = mangle_comment(comment) if comment
    end
  end
end


class RDoc::TopLevel
  #
  def to_h
    {
       :path     => path,
       :name     => base_name,
       :fullname => full_name,
       :rootname => absolute_name,
       :modified => last_modified,
       :diagram  => diagram
    }
  end

  #
  def to_json
    to_h.to_json
  end
end


class RDoc::ClassModule
  #
  def with_documentation?
    document_self_or_methods || classes_and_modules.any?{ |c| c.with_documentation? }
  end

  #
  def document_self_or_methods
    document_self || method_list.any?{ |m| m.document_self }
  end

#  #
#  def to_h
#    {
#      :name       => name,
#      :fullname   => full_name,
#      :type       => type,
#      :path       => path,
#      :superclass => module? ? nil : superclass
#    }
#  end
#
#  def to_json
#    to_h.to_json
#  end
end


class RDoc::AnyMethod

#  # NOTE: dont_rename_initialize isn't used
#  def to_h
#    {
#      :name         => name,
#      :fullname     => full_name,
#      :prettyname   => pretty_name,
#      :path         => path,
#      :type         => type,
#      :visibility   => visibility,
#      :blockparams  => block_params,
#      :singleton    => singleton,
#      :text         => text,
#      :aliases      => aliases,
#      :aliasfor     => is_alias_for,
#      :aref         => aref,
#      :parms        => params,
#      :callseq      => call_seq
#      #:paramseq     => param_seq,
#    }
#  end

#  #
#  def to_json
#    to_h.to_json
#  end

  #
  def source_code_raw
    return '' unless @token_stream
    src = ""
    @token_stream.each do |t|
      next unless t
      src << t.text
    end
    #add_line_numbers(src)
    src
  end

  #
  def source_code_location
    src = source_code_raw
    if md = /File (.*?), line (\d+)/.match(src)
      file = md[1]
      line = md[2]
    else
      file = "(unknown)"
      line = 0
    end
    return file, line
  end

end

