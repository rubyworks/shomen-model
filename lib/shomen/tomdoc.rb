require 'tomdoc'
require 'shomen/metadata'
require 'shomen/model'  # TODO: have metadata in model

module TomDoc

  module Generators

    # Shomen generator for TomDoc.
    #
    # IMPORTANT: Unfortunately TomDoc's parser does not yet provide enough
    # information to generate a substantial Shomen model. As things currently
    # stand THIS GENERATOR IS NOT USABLE. Hopefully in time the missing 
    # information will be added, and this can become a real option.
    class Shomen < Generator

      #
      def initialize(options = {}, scopes = {})
        super(options, scopes)
        @table = {}
      end

      #
      def table; @table; end

      #
      def write_scope_header(scope, prefix)
        # TODO: is it a module or class ?
        model = ::Shomen::Model::Module.new
        model = ::Shomen::Model::Class.new

        model.name    = scope.name.to_s
        model.path    = prefix.to_s + scope.name.to_s
        model.comment = clean(scope.comment.strip)

        @table[model.path] = model.to_h
      end

      #
      def write_class_methods(scope, prefix)
        prefix ="#{prefix}#{scope.name}."

        scope.class_methods.map do |method|
          next if !valid?(method, prefix)
          write_method(method, prefix, 'class')
        end.compact
      end

      #
      def write_method(tomdoc_method, prefix='', kind='instance')
        model = ::Shomen::Model::Method.new

        doc = ::TomDoc::TomDoc.new(tomdoc_method.comment)

        model.path        = prefix + tomdoc_method.name.to_s
        model.name        = tomdoc_method.name.to_s
        model.namespace   = prefix.chomp('#').chomp('.')
        # TODO: add examples to description or should shomen support examples?
        model.comment     = doc.description

        model.format      = 'tomdoc'
        #model.aliases     = tomdoc_method.aliases.map{ |a| method_name(a) }
        #model.alias_for   = method_name(tomdoc_method.is_alias_for)
        model.singleton   = (kind == 'class')

        model.declarations << kind

        # TODO: how to get visibility?
        #model.declarations << tomdoc_method.visibility.to_s

        #model.interfaces = []
        #if tomdoc_method.call_seq
        #  tomdoc_method.call_seq.split("\n").each do |cs|
        #    cs = cs.to_s.strip
        #    model.interfaces << parse_interface(cs) unless cs == ''
        #  end
        #end

        model.interfaces = []
        model.interfaces << parse_interface(tomdoc_method, doc)

        model.returns = doc.returns
        model.raises  = doc.raises

        # TODO: tomdoc doesn't provide these, so we are S.O.L.
        # model.file       = '/'+tomdoc_method.source_code_location.first
        # model.line       = tomdoc_method.source_code_location.last.to_i
        # model.source     = tomdoc_method.source_code_raw

        #if tomdoc_method.respond_to?(:c_function)
        #  model.language = tomdoc_method.c_function ? 'c' : 'ruby'
        #else
          model.language = 'ruby'
        #end

        @table[model.path] = model.to_h
      end

    private

      # Parse method interface.
      def parse_interface(method, doc)
        args, block = [], {}

        #interface, returns = interface.split(/[=-]\>/)
        #interface = interface.strip
        #if i = interface.index(/\)\s*\{/)
        #  block['signature'] = interface[i+1..-1].strip
        #  interface = interface[0..i].strip
        #end

        #arguments = interface.strip.sub(/^.*?\(/,'').chomp(')')
        #arguments = arguments.split(/\s*\,\s*/)
        doc.args.each do |a|
          name = a.name.to_s
          desc = a.description

          if name.start_with?('&')
            block['name'] = name
          else
            h = {'name'=>name,'comment'=>desc}
            # TODO: doesn't look like tomdoc is providing argument defaults :(
            if e = method.args.find{ |x| /^#{name}/ =~ x }
              n,v = e.to_s.split('=')
              h['default'] = v if v
            end
            args << h
          end
        end

        result = {}
        result['signature'] = "#{method.name}(#{method.args.join(',')})"
        result['arguments'] = args
        result['block']     = block unless block.empty?
        #result['returns']   = returns.strip if returns
        return result
      end

      # Remove hash prefixes from raw comment.
      def clean(comment)
        clean = comment.split("\n").map do |line|
          line =~ /^(\s*# ?)/ ? line.sub($1, '') : nil
        end.compact.join("\n")
        clean
      end

    end

  end

end
