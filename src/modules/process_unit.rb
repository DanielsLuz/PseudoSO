class ProcessUnit
  attr_accessor :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :num_code_disk

  def initialize(init_time, priority, processor_time, memory_blocks, printer, scanner, modem, num_code_disk)
    @init_time = init_time
    @priority = priority
    @processor_time = processor_time
    @memory_blocks = memory_blocks
    @printer = printer
    @scanner = scanner
    @modem = modem
    @num_code_disk = num_code_disk
  end
end
