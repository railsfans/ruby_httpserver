require 'socket'
require './lib/servlet'

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
               displayfile = Webserver::find_file(filename)
               content = displayfile.read()
               puts content if filename.empty?
               session.print content 
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
         File.open(basepath + '/routes.rb', 'r') do |file_handle|
            file_handle.each_line do |line|
               split_line = line.split('=')
               routes[split_line[1]] = split_line[0]   
            end
         end
          
         Dir[basepath + '/servlets/*.rb'].each {|file| require file } 
         #mount ALL the servlets!
         Webserver::Servlet.descendants.each do |clazz|
            self.mount(routes[clazz.name], clazz.new)
         end 
      end 

      def route(route, method)
         view = 'File not found'
         if @servlets.has_key?(route)
            case method
            when 'GET'
               view = @servlets[route].do_GET
            when 'POST'
               view = @servlets[route].do_POST
            else
            end 
         end 
         return view
      end 
   end

   def self.trim_heading(heading, method)
      heading.gsub(/#{method}\ \//, '').gsub(/\ HTTP.*/, '')
   end 

   def self.find_file(path)
      basepath = "./app/"
      #have to use rb here or else images don't show up properly
      open_options = 'rb'
      if path.empty?
         full_path = basepath + 'index.html'
         open_options = 'r'
      else
         full_path = basepath + path
      end 
      found_file = File.open(full_path, open_options)
      return found_file 
   end 

   def self.get_content_type(path)
      ext = File.extname(path).downcase
      puts ext
      return "text/html"  if ext.include? ".html" or ext.include? ".htm"
      return "text/plain" if ext.include? ".txt"
      return "text/css"   if ext.include? ".css"
      return "image/jpeg" if ext.include? ".jpeg" or ext.include? ".jpg"
      return "image/gif"  if ext.include? ".gif"
      return "image/bmp"  if ext.include? ".bmp"
      return "image/png" if ext.include? ".png"
      return "text/plain" if ext.include? ".rb"
      return "text/xml"   if ext.include? ".xml"
      return "text/xml"   if ext.include? ".xsl"
      return "text/html"
   end

   #TODO: refactor this using chomp instead of slice
   def self.parse_http_request(request)
      headers = {}

      #get the heading (first line)
      headers['Heading'] = request.gets.gsub /^"|"$/, ''.tap{|val|val.slice!('\r\n')}.strip
      method = headers['Heading'].split(' ')[0]

      #request is going to be a TCPsocket object 
      #parse the header
      while true
         #do inspect to get the escape characters as literals
         #also remove quotes
         line = request.gets.inspect.gsub /^"|"$/, ''

         puts line
         #if the line only contains a newline, then the body is about to start
         break if line.eql? '\r\n'

         label = line[0..line.index(':')-1]

         #get rid of the escape characters
         val = line[line.index(':')+1..line.length].tap{|val|val.slice!('\r\n')}.strip
         headers[label] = val
      end 

      #If it's a post, then we need to get the body
      headers['Body'] = request.read(headers['Content-Length'].to_i) if method.eql?('POST')
      puts headers['Body'] if headers.has_key?('Body')

      return headers
   end 

   #takes the post body and makes it into a key/val map
   def self.parse_post_body(post_body)
      parsed_attr = {}
      post_body.split('&').each do |key_val|
         split_key_val = key_val.split('=')
         parsed_attr[split_key_val[0]] = split_key_val[1]
      end 
      return parsed_attr
   end 
end 

