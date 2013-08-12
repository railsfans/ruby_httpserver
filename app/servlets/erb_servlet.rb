Dir['../lib/'].each {|file| require file } 
require 'erb'

class ERBServlet < Webserver::Servlet
   def do_GET(session, request)
      view = Webserver::find_file('views/test.html.erb').read
      puts request['Cookie']
      vars = {some_var: 'boo'}
      session.print Webserver::render_erb(view, vars)
   end 
end 
