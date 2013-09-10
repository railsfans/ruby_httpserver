require '../lib/magic_server'
require 'erb'
include MagicServer

class ERBServlet < MagicServer::Servlet
  def do_GET(session, request)
    puts request
    view = MagicServer::find_file('views/test.html.erb')
    response = ''
    response << HTTP_SUCCESS
    cookie = MagicServer::Cookie.new('booya', 'shazam') 
    response << MagicServer::set_cookie(cookie.to_s)
    response << MagicServer::content_type(HTML_TYPE)
    message = 'This page demonstrates the use of eruby with this webserver.' 
    message << ' You can modify the text that shows up in this message'
    message << 'by opening up ERBServlet located in app/servlets'
    vars = {some_var: message}
    response << MagicServer::render_erb(view, vars)
    session.print(response)
  end 
end 
