require 'socket'
require 'openssl'

require_relative 'magic_server/servlet'
require_relative 'magic_server/server_utils'
require_relative 'magic_server/server_constants'
require_relative 'magic_server/cookie'
require_relative 'magic_server/errors'
require_relative 'magic_server/utils'
require_relative 'magic_server/logger_util'
require_relative 'magic_server/ssl'
require_relative 'magic_server/mysql_helper'
include MagicServer

module MagicServer

  class Server
    attr_accessor :port, :host, :servlets

    # args is an array passed in from run.rb
    def initialize(args = [])
      @command = args[0]
      @port =  3000
      @host = '0.0.0.0'
      @servlets = {}
      #@request = { server_name: @host.to_s, server_port: @port.to_s,
        #server_protocol: SERVER_PROTOCOL }
      @request = { :server_name =>  @host.to_s, :server_port => @port.to_s,
        :server_protocol => SERVER_PROTOCOL }

      if args[0].is_a?(String)
        @host = args[1] if args[0].include? 'h'
        @port = args[1] if args[0].include? 'p'
        if args[0].include? 's'
          @ssl = true 
          @port = 443
        end 
      end 
      @logger = LoggerUtil.instance
   
      @mysql_server_ip = '127.0.0.1'
      @mysql_username = 'root'
      @mysql_passwd = 'root'
      @mysql_db = 'test'
    end 

    # This is where the application really begins. This method
    # creates the 
    def start
      self.mount_all(MagicServer::BASE_PATH)
      server = TCPServer.new @host, @port

      if @ssl
        ssl = SSL.new(File.open(CERT_PATH), File.open(KEY_PATH))
        server = ssl.ssl_server(server)
      end 

      # Create a server loop
      puts "Server created at #{@host} and port #{@port}"
      
      # Connect mysql
      mysql_helper=MagicServer::MysqlHelper.new
      mysql_helper.open(@mysql_server_ip, @mysql_user, @mysql_passwd, @mysql_db)

      begin
        #while connection = server.accept
        loop do
          begin 
            connection = server.accept
          rescue OpenSSL::SSL::SSLError 
            puts 'HTTP connection attempted when SSL enabled'
          end 
          if connection
            Thread.start(connection) do |connection|
              
              # parse the entire request into a key/val map
              request = @request.update MagicServer::parse_http_request(connection)
              heading = request['Request-Line']
              @logger.info(heading)

              # Get the method from the heading
              method = heading.split(' ')[0]
              
              # Remove everything except the path from the heading
              route = MagicServer::parse_heading(heading, method)[:route] 
              request[:path] = route.to_s
              request[:query_string] = heading.split(' ')[1].split('?')[1].to_s
              puts route.to_s+' this is route'
              begin
                self.route(route, method, connection, request)
              rescue Errno::ENOENT => e
                # Catch file not founds
                puts e.to_s
                puts e.backtrace
                connection.print "File not found"
              end
              connection.close
            end 
          end 
        end 
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
        #load all the application servlets
        Dir[MagicServer::BASE_PATH + '/servlets/*.rb'].each {|file| require file } 

        #mount ALL the servlets!
        MagicServer::Servlet.descendants.each do |clazz|
          self.mount(routes[clazz.name], clazz.new)
        end 
      end 
    end 

    # If the requested route is a static file (like javascript, css, or image)
    # then the route will be handled in the else condition. If the route is 
    # found on the servlets map, then handle it with a servlet
    def route(route, method, session, request)
      view = 'File not found'
      if @servlets.has_key?(route)
        case method
        when 'GET'
          view = @servlets[route].do_GET(session, request)
        when 'POST'
          view = @servlets[route].do_POST(session, request)
        else
        end 
      elsif route.to_s.empty?
        @servlets['/'].do_GET(session, request)
      else
        # All static file requests go here
        raw_content_type = MagicServer::get_content_type(route)
        content_type = MagicServer::content_type(raw_content_type)
        response = '' << HTTP_SUCCESS << content_type << "\n" 
        response << MagicServer::find_file(route)
        session.print(response)
      end 
      return view
    end 
  end
end 

