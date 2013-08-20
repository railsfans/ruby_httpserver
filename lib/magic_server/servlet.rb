module MagicServer
   class Servlet
      def do_GET(session, request)
         raise Errno::ENOENT
      end
      def do_POST(session, request)
         raise Errno::ENOENT
      end 
      def self.descendants
         ObjectSpace.each_object(Class).select { |clazz| clazz < self }
      end
   end 
end 

