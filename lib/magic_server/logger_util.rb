require 'logger'  
require 'singleton'

class LoggerUtil
  include Singleton

  LOG_LOCATION = './logs/log.txt'.freeze

  def initialize
    log_out = STDOUT
    log_out = LOG_LOCATION if File.exists? LOG_LOCATION
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
