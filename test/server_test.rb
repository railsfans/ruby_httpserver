require './lib/server'
require 'test/unit'

class ServerTest < Test::Unit::TestCase
   def test_trim_request
      test_header = 'GET /boo HTTP/1.1' 
      assert_equal 'boo', trim_request(test_header)
   end 

   def test_get_content_type
      test_trimmedrequest = "/css/application.css"
      puts get_content_type(test_trimmedrequest)
      assert_equal get_content_type(test_trimmedrequest), "text/css"
   end 
end 
