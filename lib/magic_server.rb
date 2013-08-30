require 'socket'

require_relative 'magic_server/servlet'
require_relative 'magic_server/server_utils'
require_relative 'magic_server/server_constants'
require_relative 'magic_server/cookie'
require_relative 'magic_server/errors'
require_relative 'magic_server/utils'
require_relative 'magic_server/logger_util'
include MagicServer

module MagicServer

  class Server
    attr_accessor :port, :host, :servlets

    # args is an array passed in from run.rb
    def initialize(args)
      @command = args[0]
      @port = 3333
      @host = '127.0.0.1'
      @servlets = {}
      if args[0].is_a?(String)
        @host = args[1] if args[0].include? 'h'
        @port = args[1] if args[0].include? "p"
      end 
      @logger = LoggerUtil.instance
    end 

    # This is where the application really begins. This method
    # creates the 
    def start
      puts "Server created at #{@host} and port #{@port}"

      self.mount_all(MagicServer::BASE_PATH)

      # Create a server loop
      Socket.tcp_server_loop(@host, @port) do |connection|
        # parse the entire request into a key/val map
        parsed_request = MagicServer::parse_http_request(connection)
        heading = parsed_request['Request-Line']
        @logger.info(heading)

        # Get the method from the heading
        method = heading.split(' ')[0]

        # Remove everything except the path from the heading
        parsed_request = MagicServer::parse_heading(heading, method)
        route = parsed_request[:route]
        puts route
        begin
          self.route(route, method, connection, parsed_request)
        rescue Errno::ENOENT => e
          # Catch file not founds
          puts e.to_s
          puts e.backtrace
          connection.print "File not found"
        end
        connection.close
      end
    end 

    def mount(route, servlet)
      @servlets[route] = servlet   
    end 

    #mount all servlets and match them up with their respective routes
    def mount_all(basepath)
      routes = {}

      #put all the routes into a map of classname/routes 
      full_path = basepath + '/routes' 
      if File.exists? full_path
        File.open(basepath + '/routes', 'r') do |file_handle|
          file_handle.each_line do |line|
            split_line = line.split('=')
            #chomp to get rid of the newline
            routes[split_line[1].chomp] = split_line[0]   
          end
        end
      end 
      #load all the application servlets
      Dir[MagicServer::BASE_PATH + '/servlets/*.rb'].each {|file| require file } 

      #mount ALL the servlets!
      MagicServer::Servlet.descendants.each do |clazz|
        self.mount(routes[clazz.name], clazz.new)
      end 
    end 

    # If the requested route is a static file (like javascript, css, or image)
    # then the route will be handled in the else condition. If the route is 
    # found on the servlets map, then handle it with a servlet
    def route(route, method, session, parsed_request)
      view = 'File not found'
      if @servlets.has_key?(route)
        case method
        when 'GET'
          view = @servlets[route].do_GET(session, parsed_request)
        when 'POST'
          view = @servlets[route].do_POST(session, parsed_request)
        else
        end 
      elsif route.to_s.empty?
        @servlets['/'].do_GET(session, parsed_request)
      else
        # All static file requests go here
        content_type = MagicServer::content_type(MagicServer::get_content_type(route))
        response = '' << HTTP_SUCCESS << content_type << "\n"
        response << MagicServer::find_file(route)
        session.print(response)
      end 
      return view
    end 
  end
end 

