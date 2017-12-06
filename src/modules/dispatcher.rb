class Dispatcher
  attr_accessor :processes
  attr_reader :processor_time, :disk_unit, :queue_unit, :memory_unit, :io_resource_unit
  attr_reader :discarded_processes

  def initialize
    @processes = Concurrent::Array.new []
    @disk_unit = DiskUnit.new(10)
    @memory_unit = MemoryUnit.new
    @queue_unit = QueueUnit.new
    @io_resource_unit = IOResourceUnit.new
    @processor_time = 0
    @logger = OSLog.instance
    @discarded_processes = []
  end

  def run
    @logger.info(self, "Starting OS...")
    load_resources
    @logger.info(self, "Initial disk: \n#{@disk_unit.disk}")
    execute
    @logger.info(self, "Final disk: \n#{@disk_unit.disk}")
    log_discarded_processes if @discarded_processes.any?
  end

  def execute
    step until @processes.all?(&:finished?)
  end

  def step
    @queue_unit.push_batch(arriving_processes)
    process = @queue_unit.pop
    @queue_unit.age_queues
    execute_process(process) if process
    @processor_time += 1
  end

  def execute_process(process)
    @logger.info(self, "Executing process (priority #{process.priority}): PID ##{process.id}")
    execute_instruction(process.step) if alocate(process)

    if process.finished?
      @logger.info(self, "Process ##{process.id} finished...")
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

  def load_resources
    load_processes(Resources.file("processes.txt"))
    load_files_data(Resources.file("files.txt"))
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
  end

  private

  def default_instruction
    @logger.info(self, "Executing default instruction...")
  end

  def arriving_processes
    arriving = @processes.select {|proc| proc.init_time == @processor_time }
                         .select {|process| valid_process?(process) }
    @logger.info(self, "#{arriving.count} arriving processes at time #{@processor_time}") if arriving.any?
    arriving
  end

  def valid_process?(process)
    @memory_unit.test(process)
  rescue MemoryUnit::ProcessTooBigError => exception
    discard(exception.class, process)
    false
  end

  def discard(reason, process)
    @logger.info(self, "Discarding process... Reason #{reason}\n#{process.attributes}")
    @processes.delete(process)
    @discarded_processes << [reason, process]
  end

  def alocate_memory(process)
    @memory_unit.alocate(process)
  end

  def alocate_devices(process)
    devices = process.devices
    return true if process.devices.empty?
    @io_resource_unit.alocate_devices(process.id, devices)
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

  def log_discarded_processes
    @logger.info(self, "Discarded processes:")
    @discarded_processes.each do |reason, process|
      @logger.info(self, "#{reason} => #{process.attributes}")
    end
  end
end
