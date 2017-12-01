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

  shared_examples_for "a dealocatable device" do |dealocate_function, device_array, alocate_function|
    let(:io_resource_unit) { subject.new(device_array => 1) }
    let(:pid) { 1 }

    context "when alocated for that pid" do
      before(:each) do
        io_resource_unit.send(alocate_function, pid)
      end

      it "dealocates correctly" do
        io_resource_unit.send(dealocate_function, pid)
        expect(io_resource_unit.send(device_array)).to_not include(pid)
      end
    end

    context "when not alocated for that pid" do
      it "behaves correctly" do
        io_resource_unit.send(dealocate_function, pid)
        expect(io_resource_unit.send(device_array)).to_not include(pid)
        expect(io_resource_unit.send(device_array)).to have_length_of(1)
      end
    end
  end

  describe "scanners" do
    it_behaves_like "an alocatable device", :alocate_scanner, :scanners
    it_behaves_like "a dealocatable device", :dealocate_scanner, :scanners, :alocate_scanner
  end

  describe "printers" do
    it_behaves_like "an alocatable device", :alocate_printer, :printers
    it_behaves_like "a dealocatable device", :dealocate_printer, :printers, :alocate_printer
  end

  describe "modems" do
    it_behaves_like "an alocatable device", :alocate_modem, :modems
    it_behaves_like "a dealocatable device", :dealocate_modem, :modems, :alocate_modem
  end

  describe "sata_devices" do
    it_behaves_like "an alocatable device", :alocate_sata_device, :sata_devices
    it_behaves_like "a dealocatable device", :dealocate_sata_device, :sata_devices, :alocate_sata_device
  end
end
