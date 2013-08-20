require 'socket'

require_relative 'magic_server/servlet'
require_relative 'magic_server/server_utils'
require_relative 'magic_server/server_constants'
require_relative 'magic_server/cookie'
require_relative 'magic_server/errors'
require_relative 'magic_server/utils'
require_relative 'magic_server/logger_util'

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

      def start
         @server = TCPServer.new(@host, @port)
         puts "Server created at #{@host} and port #{@port}"
         self.mount_all(MagicServer::BASE_PATH)
         while (session = @server.accept)
            #parse the entire request into a key/val map
            parsed_request = MagicServer::parse_http_request(session)
            heading = parsed_request['Heading']
            @logger.info(heading)

            #Get the method from the heading
            method = heading.split(' ')[0]

            #Remove everything except the path from the heading
            trimmedrequest = MagicServer::trim_heading(heading, method)
            ct = MagicServer::get_content_type(trimmedrequest)
            filename = trimmedrequest.chomp
            begin
               self.route(filename, method, session, parsed_request)
            rescue => exception
               puts exception.to_s
               puts exception.backtrace
               session.print "File not found"
            end
            session.close
         end
      end 

      def mount(route, servlet)
         @servlets[route] = servlet   
      end 

      #mount all servlets and match them up with their respective routes
      def mount_all(basepath)
         routes = {}
         
         #put all the routes into a map of classname/routes 
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
         elsif route.empty?
            @servlets['/'].do_GET(session, parsed_request)
         else
            displayfile = MagicServer::find_file(route)
            content = displayfile.read()
            session.print content 
         end 
         return view
      end 
   end
end 

