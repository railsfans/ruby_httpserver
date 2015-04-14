Gem::Specification.new do |s|
  s.name        = 'http_server'
  s.description = 'a simple http webserver'
  s.version     = '0.0.0'
  s.files = Dir.glob("{bin,lib, examples}/**/*")
  s.summary = 'A basic HTTP web server'
  s.authors = ['railsfans']
  s.executables << 'magicserver'
  s.license = 'MIT'
  s.email='yangxiangxiao@gmail.com'
  s.homepage='https://github.com/railsfans'
end
