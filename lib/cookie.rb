module Webserver
   class Cookie
      attr_accessor :name
      attr_accessor :value
      attr_accessor :expiration
      attr_accessor :domain

      def initialize(name, value)
         @name = name
         @value = value
         @expiration = nil
         @domain = nil
      end 

      #Given the contents of the 'Cookie' heading, create an array of cookie obj     
      def self.parse(cookie_str)
         ret = {}
         split_cookie = cookie_str.split(';').map { |crumb| crumb.strip }
         split_cookie.each do |crumb|
            key_val = crumb.split('=')
            ret[key_val[0]] = key_val[1]
         end 
         ret
      end 
   end 
end 
