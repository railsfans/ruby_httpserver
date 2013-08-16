require 'logger'  
require 'singleton'

class LoggerUtil
   include Singleton

   def initialize
      @log = Logger.new('log.txt')
   end 

   def debug(msg)
      @log.debug(msg)
   end 

end 
