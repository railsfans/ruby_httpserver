Gem::Specification.new do |s|
  s.name        = 'magic_server'
  s.description = 'a simple http webserver'
  s.version     = '0.0.0'
  s.files = Dir.glob("{bin,lib, examples}/**/*")
  s.summary = 'A basic HTTP web server'
  s.authors = ['David Mai']
  s.executables << 'magicserver'
  s.license = 'MIT'
  s.email='gs9600@gmail.com'
  s.homepage='https://github.com/sayonarauniverse/magic_server'
end
