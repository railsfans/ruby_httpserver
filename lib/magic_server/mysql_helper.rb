require "mysql2"
module MagicServer
   class MysqlHelper
      attr_accessor :mysql_server_ip, :mysql_user, :mysql_passwd, :mysql_db
      def initialize()
	@retries=3
      end
      def open(mysql_server_ip, mysql_user, mysql_passwd, mysql_db)
	begin
         dbc = Mysql2::Client.new(:host=>mysql_server_ip, :username=>mysql_user, :password=>mysql_passwd, :database=>mysql_db)
	 res = dbc.query('select * from test')
         rescue Mysql2::Error => e
         	puts e.errno
                puts e.error
                if @retries>0
                	puts "reconnect mysql after 1s"
                        @retries -=1
                        sleep 1
                        retry
                else
                        puts "can't connect mysql after try 3 times"
                end
         else
                puts "connect mysql success"
         ensure
                dbc.close if dbc
         end
      end 
   end
end
