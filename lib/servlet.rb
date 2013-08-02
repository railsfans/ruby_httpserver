require 'debugger'

module Webserver
   class Servlet
      def self.do_GET(req)
        raise HTTPStatus::NotFound, "not found."
      end
   end 
end 

