desc 'Opens a pry session with the project files loaded'
task :console do
  require 'bundler'
  require 'pry'
  Bundler.setup
  ARGV.clear
  binding.pry
end
