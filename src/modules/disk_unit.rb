class DiskUnit
  class SpaceNotAvailableError < StandardError
    attr_accessor :message
    def initialize(data)
      @message = "Could not create file '#{data}'. Space not available."
    end
  end

  attr_reader :disk

  def initialize(size)
    @disk = Concurrent::Array.new(size)
    @logger = OSLog.instance
  end

  def write_file(data, size)
    address = initial_address(size)
    raise SpaceNotAvailableError.new(data) unless address
    write(data, address, size)
    address
  rescue SpaceNotAvailableError => error
    @logger.info(self, "FAILED => #{error.message}")
    return nil
  end

  def write(data, address, size)
    return false unless @disk[address, size].all?(&:nil?)
    @disk[address, size] = Concurrent::Array.new(size, data)
    @logger.info(self, "Created file '#{data}'. Blocks #{address} to #{address + size}.")
  end

  def delete_file(data)
    first_index, size = @disk.index(data), @disk.count(data)
    @disk[first_index, size] = Concurrent::Array.new(size, nil)
    @logger.info(self, "Deleted file '#{data}'.")
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
