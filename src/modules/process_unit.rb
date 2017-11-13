class ProcessUnit
  attr_reader :id, :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :num_code_disk
  attr_reader :instruction_index
  attr_accessor :instructions

  def initialize(id, init_time, priority, processor_time, memory_blocks, printer, scanner, modem, num_code_disk)
    @id = id
    @init_time = init_time
    @priority = priority
    @processor_time = processor_time
    @memory_blocks = memory_blocks
    @printer = printer
    @scanner = scanner
    @modem = modem
    @num_code_disk = num_code_disk
    @instructions = Concurrent::Array.new processor_time, :default
    @instruction_index = -1
  end

  def step
    @instruction_index += 1
    @instructions[@instruction_index]
  end

  def replace_default_instruction(operation, data, size)
    @instructions[@instructions.index(:default)] = parse_instruction(operation, data, size)
  end

  def attributes
    {
      id:             @id,
      init_time:      @init_time,
      priority:       @priority,
      processor_time: @processor_time,
      memory_blocks:  @memory_blocks,
      printer:        @printer,
      scanner:        @scanner,
      modem:          @modem,
      num_code_disk:  @num_code_disk,
      instructions:   @instructions
    }
  end

  private

  def parse_instruction(operation, data, size)
    case operation
    when "0"
      [:write, data, size.to_i]
    when "1"
      [:delete, data]
    end
  end
end
