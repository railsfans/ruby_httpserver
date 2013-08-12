module Webserver
   class Servlet
      def do_GET(session, request)
         raise HTTPStatus::NotFound, "not found."
      end
      def do_POST(session, request)
         raise HTTPStatus::NotFound, "not found."
      end 
      def self.descendants
         ObjectSpace.each_object(Class).select { |clazz| clazz < self }
      end
   end 
end 

