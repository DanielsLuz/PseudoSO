require File.expand_path('../boot', __FILE__)
Dir["#{File.dirname(__FILE__)}/../src/**/*.rb"].each { |f| require f }

Bundler.require

module PseudoSO
  class Application
  end
end
