class MemoryUnit
  def initialize(real_time_memory=Concurrent::Array.new(64), user_memory=Concurrent::Array.new(960))
    @real_time_memory = real_time_memory
    @user_memory = user_memory
  end

  def size
    @real_time_memory.size + @user_memory.size
  end

  def alocate(process)
    memory = process.real_time_process? ? @real_time_memory : @user_memory
    address = initial_address(memory, process)
    return false if address.nil?
    write(memory, address, process)
    address
  end

  def written_blocks
    (@real_time_memory + @user_memory).reject(&:nil?).count
  end

  private

  def write(memory, address, process)
    memory[address, process.memory_blocks] = Concurrent::Array.new(process.memory_blocks, process.id)
  end

  def initial_address(memory, process)
    initial_address = nil
    memory.each_with_index {|elem, index|
      next unless elem.nil?
      memory_slot = memory[index, process.memory_blocks]
      break if memory_slot.size < process.memory_blocks
      return index if memory_slot.all?(&:nil?)
    }
    initial_address
  end
end
