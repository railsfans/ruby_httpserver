require 'socket'
require 'debugger'

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
            request = session.gets
            headers = Array.new
            while true
               line = session.gets
               puts line.inspect
               if line.eql? "\r\n"
                  break
               end 
               headers << line
            end 
            puts "body? " + session.read(28)
            puts "request " + request
            trimmedrequest = Webserver::trim_request(request)
            ct = Webserver::get_content_type(trimmedrequest)
            session.print "HTTP/1.1 200/OK\nContent-type:#{ct}\n\n"
            puts"HTTP/1.1 200/OK\nContent-type:#{ct}\n\n" 
            filename = trimmedrequest.chomp
            begin
               displayfile = Webserver::find_file(filename)
               content = displayfile.read()
               session.print content
            rescue Errno::ENOENT
               session.print "File not found"
            end
            session.close
         end
      end 
   end

   def mount(route, servlet)
      @servlet[route] = servlet   
   end 

   def self.trim_request(request)
      request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
   end 

   def self.find_file(path)
      basepath = "./app/"
      if path.empty?
         full_path = basepath + 'index.html'
      else
         full_path = basepath + path
      end 
      File.open full_path, 'rb'
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

   def self.parseHTTPRequest(request)

   end 
end 

