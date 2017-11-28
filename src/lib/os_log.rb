require "logger"

class OSLog
  def self.create_logger(classname)
    @logger = Logger.new("logs/last_run.log")
    @logger.level = Logger::DEBUG
    @logger.datetime_format = "%H:%M:%S "
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{classname} =>\n\t\t\t\t#{msg}\n"
    end
    @logger
  end
end
