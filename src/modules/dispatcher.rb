class Dispatcher
  attr_accessor :processes
  attr_reader :processor_time, :disk_unit, :queue_unit, :memory_unit, :io_resource_unit

  def initialize
    @processes = Concurrent::Array.new []
    @disk_unit = DiskUnit.new(10)
    @memory_unit = MemoryUnit.new
    @queue_unit = QueueUnit.new
    @io_resource_unit = IOResourceUnit.new
    @processor_time = 0
    @logger = OSLog.instance
  end

  def run
    @logger.info(self, "Starting OS...")
    load_processes(Resources.file("processes.txt"))
    load_files_data(Resources.file("files.txt"))
    execute
    @logger.info(self, "Final disk: \n#{@disk_unit.disk}")
  end

  def execute
    step until @processes.all?(&:finished?)
  end

  def step
    @queue_unit.push_batch(arriving_processes)
    process = @queue_unit.pop
    execute_process(process) if process
    @processor_time += 1
  end

  def execute_process(process)
    @logger.info(self, "Executing process: PID ##{process.id}")
    return unless alocate(process)
    execute_instruction(process.step)
    if process.finished?
      dealocate(process)
    else
      @queue_unit.push(process)
    end
  end

  def execute_instruction(instruction_data)
    @logger.info(self, "Executing instruction: ##{instruction_data}")
    return default_instruction if instruction_data == :default
    @disk_unit.send(*instruction_data)
  end

  def alocate(process)
    if alocate_memory(process) && alocate_devices(process)
      true
    else
      dealocate(process)
      false
    end
  end

  def dealocate(process)
    @memory_unit.dealocate(process)
    @io_resource_unit.dealocate_devices(process.id)
  end

  def arriving_processes
    @processes.select {|proc| proc.init_time == @processor_time }
  end

  def load_processes(filename)
    File.readlines(filename).each_with_index do |line, index|
      @processes << ProcessUnit.new(index, *line.split(",").map(&:to_i))
    end
    @logger.info(self, "#{@processes.length} processes loaded.")
  end

  def load_files_data(filename)
    lines = File.readlines(filename).map(&:strip)
    @disk_unit = DiskUnit.new(lines.first.to_i)

    write_operations = lines[1].to_i

    perform_writing(lines[2, write_operations])
    load_instructions(lines[write_operations + 2..-1])
    @logger.info(self, "Initial disk: \n#{@disk_unit.disk}")
  end

  private

  def default_instruction
    @logger.info(self, "Executing default instruction...")
  end

  def alocate_memory(process)
    @memory_unit.alocate(process)
  end

  def alocate_devices(process)
    @io_resource_unit.alocate_devices(process.id, process.devices)
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
      process = @processes.select {|proc| proc.id == id.to_i }.first
      process.replace_default_instruction(operation, data, size) if process
    end
  end
end
