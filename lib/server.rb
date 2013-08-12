require 'socket'
require_relative 'servlet'
require_relative 'server_utils'

module Webserver

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
      end 

      def start
         @server = TCPServer.new(@host, @port)
         puts "Server created at #{@host} and port #{@port}"
         basepath = './app'   
         self.mount_all(basepath)
         while (session = @server.accept)
            #parse the entire request into a key/val map
            parsed_request = Webserver::parse_http_request(session)
            heading = parsed_request['Heading']

            #Get the method from the heading
            method = heading.split(' ')[0]

            #Remove everything except the path from the heading
            trimmedrequest = Webserver::trim_heading(heading, method)
            ct = Webserver::get_content_type(trimmedrequest)
            session.print "HTTP/1.1 200/OK\nContent-type:#{ct}\n\n"
            puts"HTTP/1.1 200/OK\nContent-type:#{ct}\n\n" 
            filename = trimmedrequest.chomp
            begin
               self.route(filename, method, session, parsed_request)
            rescue Errno::ENOENT
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
         Dir[basepath + '/servlets/*.rb'].each {|file| require file } 
         
         #mount ALL the servlets!
         Webserver::Servlet.descendants.each do |clazz|
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
            displayfile = Webserver::find_file(route)
            content = displayfile.read()
            session.print content 
         end 
         return view
      end 
   end
end 

