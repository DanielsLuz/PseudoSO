class DiskUnit
  attr_reader :disk

  def initialize(size)
    @disk = Concurrent::Array.new(size)
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
end
