require 'openssl'
include OpenSSL

module MagicServer
  class SSL
    def initialize(cert, key)
      @context = OpenSSL::SSL::SSLContext.new
      cert = X509::Certificate.new cert
      key = PKey::RSA.new key
      @context.cert, @context.key = cert, key
    end 

    def ssl_server(server)
      OpenSSL::SSL::SSLServer.new server, @context
    end 
  end
end 
