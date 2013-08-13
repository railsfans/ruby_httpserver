Dir['../lib/'].each {|file| require file } 
require 'erb'
include Webserver

class ERBServlet < Webserver::Servlet
   def do_GET(session, request)
      view = Webserver::find_file('views/test.html.erb').read
      response = "HTTP/1.1 200/OK\n"
      cookie = Webserver::Cookie.new('booya', 'shazam') 
      response << "Set-Cookie: #{cookie.to_s}\n"
      response << "Content-type:#{Webserver::HTML_TYPE}\n"
      vars = {some_var: 'boo'}
      session.print(response)
      session.print Webserver::render_erb(view, vars)
   end 
end 
