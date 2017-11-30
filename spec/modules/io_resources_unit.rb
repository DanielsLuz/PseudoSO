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

  shared_examples_for "an alocatable device" do |alocate_function, device_array|
    context "when available" do
      it "alocates correctly" do
        io_resource_unit = subject.new(device_array => 1)
        io_resource_unit.send(alocate_function, 1)
        expect(io_resource_unit.send(device_array)[0]).to eq 1
      end

      it "can alocate multiple if available slots" do
        io_resource_unit = subject.new(device_array => 2)
        io_resource_unit.send(alocate_function, 1)
        io_resource_unit.send(alocate_function, 2)
        expect(io_resource_unit.send(device_array)[0]).to eq 1
        expect(io_resource_unit.send(device_array)[1]).to eq 2
      end
    end

    context "when not available" do
      it "returns false" do
        io_resource_unit = subject.new(device_array => 0)
        expect(io_resource_unit.send(alocate_function, 1)).to eq nil
      end
    end
  end

  describe "#alocate_scanner" do
    it_behaves_like "an alocatable device", :alocate_scanner, :scanners
  end

  describe "#alocate_printer" do
    it_behaves_like "an alocatable device", :alocate_printer, :printers
  end

  describe "#alocate_modem" do
    it_behaves_like "an alocatable device", :alocate_modem, :modems
  end

  describe "#alocate_sata_device" do
    it_behaves_like "an alocatable device", :alocate_sata_device, :sata_devices
  end
end
