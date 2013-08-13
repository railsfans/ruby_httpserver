module Webserver
   HTML_TYPE='text/html'
   SUCCESS = "HTTP/1.1 200/OK\n"
   
   def self.set_cookie(cookie_str)
      return "Set-Cookie: #{cookie.to_s}\n"
   end 

   def self.content_type(type_str)
      return "Content-type:#{Webserver::HTML_TYPE}\n"
   end 
end 
