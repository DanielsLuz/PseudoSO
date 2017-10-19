class ProcessUnit
  attr_accessor :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :num_code_disk

  def initialize(params = {})
    @init_time = params[:init_time]
    @priority = params[:priority]
    @processor_time = params[:processor_time]
    @memory_blocks = params[:memory_blocks]
    @printer = params[:printer]
    @scanner = params[:scanner]
    @modem = params[:modem]
    @num_code_disk = params[:num_code_disk]
  end
end
