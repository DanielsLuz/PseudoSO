class Dispatcher
  attr_reader :processes, :disk_unit

  def initialize
    @processes = Concurrent::Array.new []
  end

  def load_processes(filename)
    File.readlines(filename).each do |line|
      @processes << ProcessUnit.new(*line.split(",").map(&:to_i))
    end
  end

  def load_disk_data(filename)
    lines = File.readlines(filename).map(&:strip)
    @disk_unit = DiskUnit.new(lines.first.to_i)
    write_operations = lines[1].to_i
    perform_writing(lines[2, write_operations])
  end

  private

  def perform_writing(operations)
    operations.each do |operation|
      data, address, size = operation.split(",").map(&:strip)
      @disk_unit.write(data, address.to_i, size.to_i)
    end
  end
end
