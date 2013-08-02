Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

Webserver::Server.new(ARGV).start
