desc 'Opens a pry session with the project files loaded'
task :console do
  require './config/application'
  require 'pry'
  ARGV.clear
  binding.pry
end

task :run do
  def remove_logs
    require 'fileutils'
    FileUtils.rm_r Dir.glob('logs/*')
  end
  require './config/application'
  require 'pry'
  remove_logs
  Dispatcher.new.run
end
