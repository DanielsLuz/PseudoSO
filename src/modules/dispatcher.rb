class Dispatcher
  attr_accessor :processes
  attr_reader :disk_unit

  def initialize
    @processes = Concurrent::Array.new []
  end

  def load_processes(filename)
    File.readlines(filename).each_with_index do |line, index|
      @processes << ProcessUnit.new(index, *line.split(",").map(&:to_i))
    end
  end

  def load_files_data(filename)
    lines = File.readlines(filename).map(&:strip)
    @disk_unit = DiskUnit.new(lines.first.to_i)

    write_operations = lines[1].to_i

    perform_writing(lines[2, write_operations])
    load_instructions(lines[write_operations + 2..-1])
  end

  private

  def perform_writing(operations)
    operations.each do |operation|
      data, address, size = operation.split(",").map(&:strip)
      @disk_unit.write(data, address.to_i, size.to_i)
    end
  end

  def load_instructions(instructions)
    instructions.each do |instruction|
      id, operation, data, size = instruction.split(",").map(&:strip)
      process = @processes.select {|process| process.id == id.to_i }.first
      process.replace_default_instruction(operation, data, size)
    end
  end
end
