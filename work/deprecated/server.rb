#require 'sinatra'

#set :run, true
#set :static, true
#set :public_folder, ARGV[1] || Dir.pwd

#get '/' do
#  redirect 'index.html'
#end

require 'fileutils'
require 'tmpdir'
require 'optparse'

require 'rack'
require 'rack/server'
require 'rack/handler'
require 'rack/builder'
require 'rack/directory'
require 'rack/file'

module Shomen

  # Shomen::Server is a Rack-based server useful for viewing sites locally.
  # Most sites cannot be fully previewed by loading static files into a browser.
  # Rather, a webserver is required to render and navigate a site completely. 
  # So this light server is provided to facilitate this.
  #
  class Server 

    # Rack configuration file.
    RACK_FILE = 'shomen.ru'

    #
    def self.start(*argv)
      new(argv).start
    end

    # Server options, parsed from command line.
    attr :options

    # Setup new instance of Brite::Server.
    def initialize(argv)
      @options = ::Rack::Server::Options.new.parse!(argv)

      @root = argv.first || Dir.pwd

      @options[:app] = app
#      @options[:pid] = "#{tmp_dir}/pids/server.pid"

      @options[:Port] ||= '4321'
    end

    # THINK: Should we be using a local tmp directory instead?
    #        Then again, why do we need them at all, really?

#    # Temporary directory used by the rack server.
#    def tmp_dir
#      @tmp_dir ||= File.join(Dir.tmpdir, 'shomen', root)
#    end

    # Start the server.
    def start
      #ensure_shomen_site

#      # create required tmp directories if not found
#      %w(cache pids sessions sockets).each do |dir_to_make|
#        FileUtils.mkdir_p(File.join(tmp_dir, dir_to_make))
#      end

      server = ::Rack::Server.start(options)

      trap("INT") do
        server.stop
        exit
      end
    end

    ## Ensure root is a Shomen Site.
    #def ensure_shomen_site
    #  return true if File.exist?(rack_file)
    #  #return true if config.file
    #  #abort "Not a shomen site."
    #end

    ## Load Brite configuration.
    #def config
    #  @config ||= Brite::Config.new(root)
    #end

    # Site root directory.
    def root
      @root
    end

    # Configuration file for server.
    def rack_file
      RACK_FILE
    end

    # If the site has a `shomen.ru` file, that will be used to start the server,
    # otherwise a standard Rack::Directory server is used.
    def app
      @app ||= (
        if ::File.exist?(rack_file)
          app, options = Rack::Builder.parse_file(rack_file, opt_parser)
          @options.merge!(options)
          app
        else
          root = self.root
          Rack::Builder.new do
            #use Index, root
            use Rack::Static, :urls=>{'/'=>'index.html'}, :root => root
            run Rack::Directory.new("#{root}")
          end
        end
      )
    end

    # Rack middleware to serve `index.html` file by default.
    class Index
      def initialize(app, root)
        @app  = app
        @root = root || Dir.pwd
      end

      def call(env)
        path = Rack::Utils.unescape(env['PATH_INFO'])
        index_file = File.join(@root, path, 'index.html')
        if File.exists?(index_file)
          [200, {'Content-Type' => 'text/html'}, File.new(index_file)]
        else
          @app.call(env) #Rack::Directory.new(@root).call(env)
        end
      end
    end

    #
    #def middleware
    #  middlewares = []
    #  #middlewares << [Rails::Rack::LogTailer, log_path] unless options[:daemonize]
    #  #middlewares << [Rails::Rack::Debugger]  if options[:debugger]
    #  Hash.new(middlewares)
    #end

  end

end
