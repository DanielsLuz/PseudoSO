class Dispatcher
  attr_reader :processes

  def initialize
    @processes = Concurrent::Array.new []
  end

  def load_processes(filename)
    File.readlines(filename).each do |line|
      @processes << ProcessUnit.new(*line.split(",").map(&:to_i))
    end
  end
end
