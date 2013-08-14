Dir['../lib/'].each {|file| require file } 

class TestServlet < Webserver::Servlet
   def do_GET(session, request)
      response = Webserver::HTTP_SUCCESS
      response << Webserver::content_type(HTML_TYPE)
      response << Webserver::find_file('').read    
      session.print(response)
   end 
end 
