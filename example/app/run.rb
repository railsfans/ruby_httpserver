#Dir[File.dirname(__FILE__) + '../lib/*.rb'].each {|file| require file }
require '../lib/magic_server.rb'

MagicServer::Server.new(ARGV).start
