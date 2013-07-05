require 'socket'

def start(args)
   webserver = create_server args
   basepath = './app/'

   while (session = webserver.accept)
      request = session.gets
      puts "request " + request
      trimmedrequest = trim_request(request)
      ct = get_content_type trimmedrequest
      session.print "HTTP/1.1 200/OK\nContent-type:#{ct}\n\n"
      puts"HTTP/1.1 200/OK\nContent-type:#{ct}\n\n" 
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
   File.open full_path, 'rb'
end 

def get_content_type(path)
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


