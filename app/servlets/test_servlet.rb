require './lib/servlet'

class TestServlet < Webserver::Servlet
   def do_GET(session)
      view = Weberver::find_file('')    
      session.print(displayfile.read())
   end 
end 
