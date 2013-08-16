require 'time' 

module MagicServer
   class Cookie
      attr_accessor :name, :value, :expires, :domain, :max_age, :comment
      attr_accessor :path, :secure, :version

      def initialize(name, value)
         @name = name
         @value = value
         @version = 0
         @expires = nil
         @domain = nil
         @max_page = nil
         @comment = nil
         @path = nil
         @secure = nil
      end 

      def to_s
         ret = ""
         ret << @name << "=" << @value
         ret << "; " << "Version=" << @version.to_s if @version > 0
         ret << "; " << "Domain="  << @domain  if @domain
         ret << "; " << "Expires=" << @expires if @expires
         ret << "; " << "Max-Age=" << @max_age.to_s if @max_age
         ret << "; " << "Comment=" << @comment if @comment
         ret << "; " << "Path="    << @path if @path
         ret << "; " << "Secure"   if @secure
         ret
      end

      #if expires is not null, and is a time, return it
      def expires
         @expires and Time.parse(@expires)
      end 

      #set expires only if it's a time
      def expires=(t)
         @expires = t && (t.is_a?(Time) ? t.httpdate : t.to_s)
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
