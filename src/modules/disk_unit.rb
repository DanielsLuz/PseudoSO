class DiskUnit
  attr_reader :disk

  def initialize(size)
    @disk = Concurrent::Array.new(size)
  end

  def write_file(data, size)
    address = initial_address(size)
    return nil if address.nil?
    write(data, address, size)
    address
  end

  def write(data, address, size)
    return false unless @disk[address, size].all?(&:nil?)
    @disk[address, size] = Concurrent::Array.new(size, data)
  end

  def delete(data)
    @disk.delete(data)
  end

  def [](address)
    @disk[address]
  end

  def size
    @disk.size
  end

  def written_blocks
    @disk.reject(&:nil?).count
  end

  def attributes
    {
      size:    size,
      written: written
    }
  end

  private

  def initial_address(size)
    initial_address = nil
    @disk.each_with_index {|elem, index|
      next unless elem.nil?
      disk_slot = @disk[index, size]
      break if disk_slot.size < size
      return index if disk_slot.all?(&:nil?)
    }
    initial_address
  end
end
