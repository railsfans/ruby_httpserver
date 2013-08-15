puts Dir.glob("{bin,lib}/**/*")
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/test/*.rb'].each {|file| require file }
