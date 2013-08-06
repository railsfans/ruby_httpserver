require './lib/server'
require 'test/unit'

class ServerTest < Test::Unit::TestCase
   def test_trim_request
      test_header = 'GET /boo HTTP/1.1' 
      assert_equal 'boo', Webserver::trim_heading(test_header, 'GET')
   end 

   def test_get_content_type
      test_trimmedrequest = "/css/application.css"
      assert_equal Webserver::get_content_type(test_trimmedrequest), "text/css"
   end 

   def test_server_init_port
      args = ['p', '3334']
      server = Webserver::Server.new(args)
   end 

   def test_status_message
      assert_equal Webserver::StatusMessage[100], 'Continue'
   end 

   def test_servlet_mounts
      server = Webserver::Server.new([]) 
      server.mount_all('./app')
   end 
end 
