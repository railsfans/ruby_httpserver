require 'erb'
require 'ostruct'
require_relative 'utils'

module Webserver

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
      return Webserver::HTML_TYPE if ext.include? ".html" or ext.include? ".htm"
      return "text/plain" if ext.include? ".txt"
      return "text/css"   if ext.include? ".css"
      return "image/jpeg" if ext.include? ".jpeg" or ext.include? ".jpg"
      return "image/gif"  if ext.include? ".gif"
      return "image/bmp"  if ext.include? ".bmp"
      return "image/png" if ext.include? ".png"
      return "text/plain" if ext.include? ".rb"
      return "text/xml"   if ext.include? ".xml"
      return "text/xml"   if ext.include? ".xsl"
      return Webserver::HTML_TYPE
   end

   #TODO: refactor this using chomp instead of slice
   def self.parse_http_request(request)
      headers = {}

      #get the heading (first line)
      headers['Heading'] = request.gets.gsub /^"|"$/, ''.tap{|val|val.slice!('\r\n')}.strip
      method = headers['Heading'].split(' ')[0]
      puts headers['Heading']
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
   
   #renders an erb template, taking in a hash for the variables
   def self.render_erb(template, locals)
      ERB.new(template).result(OpenStruct.new(locals).instance_eval { binding })
   end
end 
