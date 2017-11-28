class Dispatcher
  attr_accessor :processes
  attr_reader :disk_unit, :processor_time, :queue_unit

  def initialize
    @processes = Concurrent::Array.new []
    @disk_unit = DiskUnit.new(10)
    @memory_unit = MemoryUnit.new
    @queue_unit = QueueUnit.new
    @processor_time = 0
  end

  def run
    loop do
      step
    end
  end

  def step
    @queue_unit.push_batch(arriving_processes)
    process = @queue_unit.pop
    execute(process) if process
    @processor_time += 1
  end

  def execute(process)
    return unless alocated_adress(process)
    process.step
    # execute process instruction
    if process.finished?
      dealocate(process)
    else
      @queue_unit.push(process)
    end
  end

  def execute_instruction(instruction_data)
    return default_instruction if instruction_data == :default
    @disk_unit.send(*instruction_data)
  end

  def alocated_adress(process)
    @memory_unit.alocate(process)
  end

  def dealocate(process)
    @memory_unit.dealocate(process)
  end

  def arriving_processes
    @processes.select {|proc| proc.init_time == @processor_time }
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

  def default_instruction
    puts "Executing default instruction..."
  end

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
