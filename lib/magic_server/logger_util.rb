require 'logger'  
require 'singleton'

class LoggerUtil
   include Singleton

   LOG_LOCATION = './logs/log.txt'.freeze

   def initialize
      log_out = ''
      if caller.last.include?('test')
         log_out = STDOUT
      else
         log_out = './logs/log.txt' 
      end 

      @log = Logger.new(log_out)
   end 

   def debug(msg)
      @log.debug(caller[0] << ' ' << msg)
   end 

   def error(msg)
      @log.error(caller[0] << ' ' << msg)
   end

   def info(msg)
      @log.info(caller[0] << ' ' << msg)
   end 

end 
