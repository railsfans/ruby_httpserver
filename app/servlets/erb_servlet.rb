Dir['../lib/'].each {|file| require file } 
require 'erb'
include Webserver

class ERBServlet < Webserver::Servlet
   def do_GET(session, request)
      view = Webserver::find_file('views/test.html.erb').read
      response = ''
      puts HTTP_SUCCESS
      response << HTTP_SUCCESS
      cookie = Webserver::Cookie.new('booya', 'shazam') 
      response << Webserver::set_cookie(cookie.to_s)
      response << Webserver::content_type(HTML_TYPE)
      message = 'This page demonstrates the use of eruby with this webserver.' 
      message << ' You can modify the text that shows up in this message'
      message << 'by opening up ERBServlet located in app/servlets'
      vars = {some_var: message}
      response << Webserver::render_erb(view, vars)
      session.print(response)
   end 
end 
