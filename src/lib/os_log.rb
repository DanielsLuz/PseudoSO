require "logger"
require "singleton"

class OSLog < Logger
  include Singleton

  ID_FORMATTER = lambda do |classname|
    lambda do |_severity, _datetime, _progname, msg|
      "=> #{classname}\n\t\t\t\t#{msg}\n"
    end
  end

  DEFAULT_FORMATTER = lambda do |_severity, _datetime, _progname, msg|
    "\t\t\t\t#{msg}\n"
  end

  def initialize
    super("logs/last_run.log")
    self.level = Logger::DEBUG
    self.datetime_format = "%H:%M:%S "
    self.formatter = DEFAULT_FORMATTER
    @last_class = nil
  end

  def info(klass, message)
    classname = klass.class.to_s
    if @last_classname != classname
      @last_classname = classname
      self.formatter = ID_FORMATTER.call(classname)
    else
      self.formatter = DEFAULT_FORMATTER
    end
    super(message)
  end
end
