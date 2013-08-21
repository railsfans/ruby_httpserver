require 'erb'
require 'ostruct'
require_relative 'utils'

module MagicServer

   # This method takes a url like this: /erbtest?boo=hello
   # and turns it into a map with :route and :arguments
   # as keys. /erbtest would be :route, and boo => hello
   # would be :arguments. The reason why this is done is
   # so that the route and the parameters can be separated
   def self.parse_heading(heading, method)
      ret = {}
      arguments = {}

      # Remove all the HTTP boilerplate
      heading.gsub!(/#{method}\ \//, '')
      heading.gsub!(/\ HTTP.*/, '')
      heading.chomp!

      #Split up the heading between the routes and the arguments
      split_heading = heading.split('?')
      ret[:route] = split_heading[0]

      #Parse the arguments into a map
      if split_heading.size > 1
         split_heading[1].split('&').each do |key_val|
            key_and_val = key_val.split('=')
            arguments[key_and_val[0]] = key_and_val[1]
         end 
      end 
      ret[:arguments] = arguments
      ret
   end 

   # Fetch a file from the file system. the 'b' in open options
   # stands for binary file mode. The reason this is used is 
   # because certain file types, like images, don't read properly
   # unless you use it. I'm not exactly sure why this is the case,
   # so it's definitely something to look into
   def self.find_file(path)
      open_options = 'rb'
      if path.empty?
         full_path = MagicServer::BASE_PATH + 'index.html'
      else
         full_path = MagicServer::BASE_PATH + path
      end 
      found_file = File.open(full_path, open_options)
      return found_file 
   end 

   # Generates the "Content-Type" heading based on the path 
   def self.get_content_type(path)
      ext = File.extname(path).downcase
      return MagicServer::HTML_TYPE if ext.include? ".html" or ext.include? ".htm"
      return "text/plain" if ext.include? ".txt"
      return "text/css"   if ext.include? ".css"
      return "image/jpeg" if ext.include? ".jpeg" or ext.include? ".jpg"
      return "image/gif"  if ext.include? ".gif"
      return "image/bmp"  if ext.include? ".bmp"
      return "image/png" if ext.include? ".png"
      return "text/plain" if ext.include? ".rb"
      return "text/xml"   if ext.include? ".xml"
      return "text/xml"   if ext.include? ".xsl"
      return 'application/javascript' if ext.include?('.js')
      return MagicServer::HTML_TYPE
   end

   # Takes a HTTP request and parses it into a map that's keyed
   # by the title of the heading and the heading itself
   def self.parse_http_request(request)
      headers = {}

      # Need to use readpartial instead of read because read will
      # block due to the lack of a EOF
      request_str = request.readpartial(1024*16)
      arrayed_request = request_str.split(/\r?\n/)
      headers['Request-Line'] = arrayed_request.shift

      # If there's a blank line, that means that there's
      # a body on the last line
      if arrayed_request.index { |line| line.strip.empty? }
         headers['Body'] = arrayed_request.pop(2)[1] 
      end 

      # For everything else, split on the first colon, and
      # dump it all into the headers map
      arrayed_request.inject(headers) {|headers, line|
         split = line.split(':')
         headers[split.shift] = split.join(':').strip
         headers
      }
      headers
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
   
   #renders an erb template, taking in a hash for the variables
   def self.render_erb(template, locals)
      ERB.new(template).result(OpenStruct.new(locals).instance_eval { binding })
   end
end 
