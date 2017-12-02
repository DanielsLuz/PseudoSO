class IOResourceUnit
  DEFAULT_DEVICES = {
    scanners:     1,
    printers:     2,
    modems:       1,
    sata_devices: 2
  }.freeze

  attr_reader :scanners, :printers, :modems, :sata_devices, :devices

  def initialize(opts={})
    opts = DEFAULT_DEVICES.merge(opts)
    @scanners = Concurrent::Array.new opts[:scanners]
    @printers = Concurrent::Array.new opts[:printers]
    @modems = Concurrent::Array.new opts[:modems]
    @sata_devices = Concurrent::Array.new opts[:sata_devices]
    @devices = {
      scanner:     @scanners,
      printer:     @printers,
      modem:       @modems,
      sata_device: @sata_devices
    }
  end

  def alocate_devices(pid, devices)
    return true if devices_alocated?(pid, devices)
    return false unless can_alocate_all? devices
    devices.each do |device|
      public_send("alocate_#{device}", pid)
    end
  end

  def dealocate_devices(pid)
    @devices.each do |_device, device_array|
      dealocate(device_array, pid)
    end
  end

  def can_alocate_all?(devices)
    devices.map {|device|
      can_alocate?(device)
    }.all?
  end

  def devices_alocated?(pid, devices)
    devices.map {|device|
      alocated?(pid, device)
    }.all?
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

  def can_alocate?(device)
    @devices[device].index(nil)
  end

  def alocated?(pid, device)
    @devices[device].index(pid)
  end
end
