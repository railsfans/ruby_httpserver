module Webserver
   class Servlet
      def do_GET(req)
        raise HTTPStatus::NotFound, "not found."
      end
      def do_POST(req)
        raise HTTPStatus::NotFound, "not found."
      end 
   end 
end 

