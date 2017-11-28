require "singleton"
require "logger"

class OSLog
  include Singleton
  def log
    unless @logger
      @logger = Logger.new STDOUT
      @logger.level = Logger::DEBUG
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S "
    end
    @logger
  end
end
