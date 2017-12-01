class IOResourceUnit
  DEFAULT_DEVICES = {
    scanners:     1,
    printers:     2,
    modems:       1,
    sata_devices: 2
  }.freeze

  attr_reader :scanners, :printers, :modems, :sata_devices

  def initialize(opts={})
    opts = DEFAULT_DEVICES.merge(opts)
    @scanners = Concurrent::Array.new opts[:scanners]
    @printers = Concurrent::Array.new opts[:printers]
    @modems = Concurrent::Array.new opts[:modems]
    @sata_devices = Concurrent::Array.new opts[:sata_devices]
  end

  def alocate_scanner(pid)
    alocate(@scanners, pid)
  end

  def dealocate_scanner(pid)
    dealocate(@scanners, pid)
  end

  def alocate_printer(pid)
    alocate(@printers, pid)
  end

  def dealocate_printer(pid)
    dealocate(@printers, pid)
  end

  def alocate_modem(pid)
    alocate(@modems, pid)
  end

  def dealocate_modem(pid)
    dealocate(@modems, pid)
  end

  def alocate_sata_device(pid)
    alocate(@sata_devices, pid)
  end

  def dealocate_sata_device(pid)
    dealocate(@sata_devices, pid)
  end

  private

  def alocate(device_array, pid)
    return unless device_array.index(nil)
    device_array[device_array.index(nil)] = pid
  end

  def dealocate(device_array, pid)
    return unless device_array.include?(pid)
    device_array[device_array.index(pid)] = nil
  end
end
