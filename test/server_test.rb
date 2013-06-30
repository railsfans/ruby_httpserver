require './lib/server'
require 'test/unit'

class ServerTest < Test::Unit::TestCase
   def test_trim_request
      test_header = 'GET /boo HTTP/1.1' 
      assert_equal 'boo', trim_request(test_header)
   end 
end 
