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

  def alocate_printer(pid)
    alocate(@printers, pid)
  end

  def alocate_modem(pid)
    alocate(@modems, pid)
  end

  def alocate_sata_device(pid)
    alocate(@sata_devices, pid)
  end

  private

  def alocate(device, pid)
    return unless device.index(nil)
    device[device.index(nil)] = pid
  end
end
