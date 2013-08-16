module MagicServer
   HTML_TYPE='text/html'.freeze
   HTTP_SUCCESS = "HTTP/1.1 200/OK\n".freeze
   BASE_PATH = './'.freeze
   
   def self.set_cookie(cookie_str)
      return "Set-Cookie: #{cookie_str}\n"
   end 

   def self.content_type(type_str)
      return "Content-type:#{type_str}\n"
   end 
end 
