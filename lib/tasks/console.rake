desc 'Opens a pry session with the project files loaded'
task :console do
  require 'bundler/setup'
  require 'pry'
  Bundler.require
  ARGV.clear
  binding.pry
end
