Dir['../lib/'].each {|file| require file } 
require 'erb'

class ERBServlet < Webserver::Servlet
   def do_GET(session)
      view = Webserver::find_file('views/test.html.erb').read
      vars = {some_var: 'boo'}
      session.print Webserver::render_erb(view, vars)
   end 
end 
