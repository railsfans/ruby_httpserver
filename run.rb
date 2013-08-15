Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
#puts Dir.glob("{lib}/**/*") 
Webserver::Server.new(ARGV).start
