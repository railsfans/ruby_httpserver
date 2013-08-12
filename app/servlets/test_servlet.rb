Dir['../lib/'].each {|file| require file } 

class TestServlet < Webserver::Servlet
   def do_GET(session, request)
      view = Webserver::find_file('')    
      session.print(view.read())
   end 
end 
