require 'socket'

def start(args)
   webserver = create_server args
   basepath = './app/'

   while (session = webserver.accept)
      puts "HTTP/1.1 200/OK\nContent-type:text/html\n\n"
      session.print "HTTP/1.1 200/OK\nContent-type:text/html\n\n"
      request = session.gets
      puts "request" + request
      trimmedrequest = trim_request(request)
      filename = trimmedrequest.chomp
      begin
         displayfile = find_file(filename)
         content = displayfile.read()
         session.print content
      rescue Errno::ENOENT
         session.print "File not found"
      end
      session.close
   end
end 

def create_server(args)
   command = args[0]
   #default port is going to be 3333
   port = 3333
   #default address will be localhost
   address = "localhost"
   port = args[1] if args[0].instance_of? String and args[0].eql? "p"
   puts "Server created at #{address} and port #{port}"
   TCPServer.new address, port
end 

def trim_request(request)
   request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
end 

def find_file(path)
   basepath = "./app/"
   if path.empty?
      full_path = basepath + 'index.html'
   else
      full_path = basepath + path
   end 
   File.open full_path, 'r'
end 

