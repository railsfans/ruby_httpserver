require '../lib/magic_server'

class TestServlet < MagicServer::Servlet
  def do_GET(session, request)
    puts request
    response = ''
    response << MagicServer::HTTP_SUCCESS
    response << MagicServer::content_type(HTML_TYPE)
    response << MagicServer::find_file('')
    session.print(response)
  end 
end 
