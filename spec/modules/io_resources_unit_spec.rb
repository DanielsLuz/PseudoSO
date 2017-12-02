describe IOResourceUnit do
  subject(:io_resource_unit) { IOResourceUnit }
  describe "#new" do
    context "when initializing" do
      it "has the default devices defined" do
        attributes = {
          scanners:     an_instance_of(Concurrent::Array).and(have_length_of(1)),
          printers:     an_instance_of(Concurrent::Array).and(have_length_of(2)),
          modems:       an_instance_of(Concurrent::Array).and(have_length_of(1)),
          sata_devices: an_instance_of(Concurrent::Array).and(have_length_of(2))
        }
        devices = {
          scanners:     1,
          printers:     2,
          modems:       1,
          sata_devices: 2
        }
        expect(subject.new(devices)).to have_attributes attributes
      end

      it "defines the arrays correctly" do
        attributes = {
          scanners:     an_instance_of(Concurrent::Array).and(have_length_of(5)),
          printers:     an_instance_of(Concurrent::Array).and(have_length_of(5)),
          modems:       an_instance_of(Concurrent::Array).and(have_length_of(5)),
          sata_devices: an_instance_of(Concurrent::Array).and(have_length_of(5))
        }
        devices = {
          scanners:     5,
          printers:     5,
          modems:       5,
          sata_devices: 5
        }
        expect(subject.new(devices)).to have_attributes attributes
      end
    end
  end

  describe "#alocate_devices" do
    let(:io_resource_unit) { subject.new }
    context "when given a pid and an array of devices" do
      let(:pid) { 0 }
      it "invokes each alocate function properly" do
        devices = [:scanner, :printer, :modem, :sata_device]
        io_resource_unit.alocate_devices(pid, devices)
        expect(io_resource_unit.scanners).to include(pid)
        expect(io_resource_unit.printers).to include(pid)
        expect(io_resource_unit.modems).to include(pid)
        expect(io_resource_unit.sata_devices).to include(pid)
      end

      it "does not alocate if device not in array" do
        devices = [:scanner]
        io_resource_unit.alocate_devices(pid, devices)
        expect(io_resource_unit.scanners).to include(pid)
        expect(io_resource_unit.printers).to_not include(pid)
        expect(io_resource_unit.modems).to_not include(pid)
        expect(io_resource_unit.sata_devices).to_not include(pid)
      end

      it "only alocates if all can be alocated" do
        devices = [:scanner, :printer, :modem, :sata_device]
        expect(io_resource_unit).to receive(:can_alocate_all?).with(devices).and_return(false)
        expect(io_resource_unit.alocate_devices(0, devices)).to eq false
      end

      it "does not alocate the same pid twice" do
        devices = [:printer] # we have two printers, but the pid should only alocate one
        2.times do
          io_resource_unit.alocate_devices(pid, devices)
        end
        expect(io_resource_unit.printers).to eq [pid, nil]
      end
    end
  end

  describe "#dealocate_devices" do
    let(:io_resource_unit) { subject.new }
    let(:pid) { 0 }
    it "dealocates all devices of a given pid" do
      io_resource_unit.alocate_devices(pid, [:scanner, :printer])
      expect(io_resource_unit.scanners).to include(pid)
      expect(io_resource_unit.printers).to include(pid)
      io_resource_unit.dealocate_devices(pid)
      expect(io_resource_unit.scanners).to_not include(pid)
      expect(io_resource_unit.printers).to_not include(pid)
    end
  end

  describe "#can_alocate_all?" do
    it "returns true if every device given can be alocated" do
      io_resource_unit = subject.new
      devices = [:scanner, :printer, :modem, :sata_device]
      expect(io_resource_unit.can_alocate_all?(devices)).to eq true
    end

    [:scanners, :printers, :modems, :sata_devices].each do |device|
      it "returns false if #{device} cannot be alocated" do
        io_resource_unit = subject.new(device => 0)
        devices = [:scanner, :printer, :modem, :sata_device]
        expect(io_resource_unit.can_alocate_all?(devices)).to eq false
      end
    end
  end

  describe "#devices_alocated?" do
    let(:io_resource_unit) { subject.new }
    let(:pid) { 0 }
    let(:devices) { [:scanner, :printer] }
    it "returns true if given pid already alocated" do
      io_resource_unit.alocate_devices(pid, devices)
      expect(io_resource_unit.devices_alocated?(pid, devices)).to eq true
    end

    it "returns false if given pid is not alocated" do
      expect(io_resource_unit.devices_alocated?(pid, devices)).to eq false
    end
  end
end
