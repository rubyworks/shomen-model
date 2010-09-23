require 'erb'

module Shomen

  # = ERB Template
  #
  # Template is used by the generator to build
  # template files. It has access to all the
  # the <i>data methods</i> in the generator.

  class Template

    include ERB::Util

    # New ERBTemplate instance.

    def initialize(generator, provisions)
      @generator = generator
      # add component provisions
      provisions.each do |name, block|
        (class << self; self; end).class_eval do
          define_method(name){ |*a,&b| block.call(*a,&b) }
        end
      end
    end

    # Render a template.

    def render(template_file, local_assigns={})
      template_source = template_file.read
      erb = ERB.new(template_source, nil, '<>')
      erb.filename = template_file.to_s

      local_assigns.each do |key, val|
        (class << self; self; end).class_eval do
          define_method(key){ val }
        end
      end

      begin
        erb_binding = binding
        #eval code, b
        erb.result(erb_binding)
      rescue NoMethodError => err
        raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
          template_file.to_s,
          err.message,
          eval("_erbout[-50,50]", erb_binding)
        ], err.backtrace
      end
    end

    # FIXME: this probably does not need to double dispatch via generator
    def include_template(*a,&b)
      @generator.include_template(*a,&b)
    end

    def options   ; @generator.options   ; end
    def title     ; @generator.title     ; end
    def copyright ; @generator.copyright ; end

    def class_dir ; @generator.class_dir ; end
    def file_dir  ; @generator.file_dir  ; end

    #def all_classes_and_modules    ; @generator.all_classes_and_modules    ; end

    # classes and modules
    def classes                    ; @generator.classes                    ; end
    def classes_toplevel           ; @generator.classes_toplevel           ; end
    def classes_salient            ; @generator.classes_salient            ; end
    def classes_hash               ; @generator.classes_hash               ; end

    # just modules, no classes
    def modules                    ; @generator.modules                    ; end
    def modules_toplevel           ; @generator.modules_toplevel           ; end
    def modules_salient            ; @generator.modules_salient            ; end
    def modules_hash               ; @generator.modules_hash               ; end

    # just classes w/o modules
    def types                      ; @generator.types                      ; end
    def types_toplevel             ; @generator.types_toplevel             ; end
    def types_salient              ; @generator.types_salient              ; end
    def types_hash                 ; @generator.types_hash                 ; end

    #
    def methods_all                ; @generator.methods_all                ; end

    #
    def files                      ; @generator.files                      ; end
    def files_toplevel             ; @generator.files_toplevel             ; end
    def files_hash                 ; @generator.files_hash                 ; end

    def find_class_named(*a,&b)    ; @generator.find_class_named(*a,&b)    ; end
    def find_module_named(*a,&b)   ; @generator.find_module_named(*a,&b)   ; end
    def find_type_named(*a,&b)     ; @generator.find_type_named(*a,&b)     ; end
    def find_file_named(*a,&b)     ; @generator.find_file_named(*a,&b)     ; end

    # Load and render the erb template with the given +template_name+ within
    # current context. Adds all +local_assigns+ to context

    def include_template(template_name, local_assigns={})
      #source = local_assigns.keys.map { |key| "#{key} = local_assigns[:#{key}];" }.join
      #eval("#{source}; templatefile = path_template + template_name;eval_template(templatefile, binding)")
      template_file = @generator.__send__(:path_template) + template_name
      render(template_file, local_assigns)
    end

    #
    def method_missing(s, *a, &b)
      if @generator.respond_to?(s)
        @generator.__send__(s, *a, &b)
      end
    end

  end

end

