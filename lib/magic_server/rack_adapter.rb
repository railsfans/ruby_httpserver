require_relative 'server_utils'

module MagicServer
  class RackAdapter
    def initialize(@servlets)
      @servlets = servlets
    end 
    def call(env)
             
    end 
  end 
end 
