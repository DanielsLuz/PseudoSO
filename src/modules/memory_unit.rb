class MemoryUnit
  def initialize(real_time_memory=Concurrent::Array.new(64), user_memory=Concurrent::Array.new(960))
    @real_time_memory = real_time_memory
    @user_memory = user_memory
  end

  def size
    @real_time_memory.size + @user_memory.size
  end

  def alocate(process)
    address = initial_address(process)
    return false if address.nil?
    @user_memory[address, process.memory_blocks] = Concurrent::Array.new(process.memory_blocks, process.id)
    address
  end

  def written_blocks
    (@real_time_memory + @user_memory).reject(&:nil?).count
  end

  private

  def initial_address(process)
    initial_address = nil
    @user_memory.each_with_index {|elem, index|
      next unless elem.nil?
      return index if @user_memory[index, process.memory_blocks].all?(&:nil?)
    }
    initial_address
  end
end
