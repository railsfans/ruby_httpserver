puts Dir.glob("{bin,lib}/**/*").class
Gem::Specification.new do |s|
  s.name        = 'simple_ws'
  s.description = 'a simple http webserver'
  s.version     = '1'
  #s.files       = Dir.glob("{bin,lib}/**/*") 
  s.files = ['lib/server_constants.rb']
  s.summary = 'A basic HTTP web server'
  s.authors = ['David Mai']
end
