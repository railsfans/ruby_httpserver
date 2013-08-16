puts Dir.glob("{bin,lib}/**/*")
Gem::Specification.new do |s|
  s.name        = 'magic_server'
  s.description = 'a simple http webserver'
  s.version     = '0.0.0'
  s.files = Dir.glob("{bin,lib}/**/*")
  s.summary = 'A basic HTTP web server'
  s.authors = ['David Mai']
end
