require File.expand_path('../boot', __FILE__)
Dir["#{File.dirname(__FILE__)}/../src/**/*.rb"].each { |f| require f }

Bundler.require

module PseudoSO
  ROOT_PATH = File.expand_path(".")

  class Application
  end
end
