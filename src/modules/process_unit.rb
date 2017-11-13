class ProcessUnit
  attr_reader :id, :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :num_code_disk
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
  end

  def replace_default_instruction(operation, data, size)
    @instructions[@instructions.index(:default)] = "#{operation}, #{data}, #{size || 0}"
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
end
