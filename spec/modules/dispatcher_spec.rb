describe Dispatcher do
  subject(:dispatcher) { Dispatcher.new }

  xdescribe "#run" do
    before(:each) do
      disk_unit = DiskUnit.new(10)

      @process0 = ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0)
      @process0.replace_default_instruction("0", "B", "2")

      @dispatcher = Dispatcher.new
      @dispatcher.processes << @process0
      allow(@dispatcher).to receive(:disk_unit).and_return(disk_unit)
    end

    it "runs until the queue is empty" do
      @dispatcher.run
      expect(@dispatcher.processes).to be_empty
      expect(@dispatcher.processor_time).to eq @process0.instructions.count + 1
    end
  end

  describe "#step" do
    let(:process_init_time0) { ProcessUnit.new(0, 0, 0, 7, 64, 1, 0, 0, 0) }
    let(:process_init_time1) { ProcessUnit.new(1, 1, 1, 7, 64, 1, 0, 0, 0) }

    it "does not push until processor time matches" do
      dispatcher.processes = [process_init_time1]
      dispatcher.step
      # does not include yet
      expect(dispatcher.queue_unit.queues[1]).to_not include(process_init_time1)

      dispatcher.step
      # includes since time matches
      expect(dispatcher.queue_unit.queues[1]).to include(process_init_time1)
    end

    it "does not push process back if finished" do
      expect(process_init_time0).to receive(:finished?).and_return true
      dispatcher.processes = [process_init_time0]
      dispatcher.step
      expect(dispatcher.queue_unit.queues[0]).to_not include(process_init_time0)
    end

    it "does push process back if alocation fails" do
      expect(dispatcher).to receive(:alocate).with(process_init_time0).and_return false
      dispatcher.processes = [process_init_time0]
      dispatcher.step
      expect(dispatcher.queue_unit.queues[0]).to include(process_init_time0)
    end

    context "when escalonating" do
      let(:big_process_init_time0) { ProcessUnit.new(0, 0, 0, 7, 1000, 1, 0, 0, 0) }

      it "pushes processes that start at that processor time" do
        dispatcher.processes = [process_init_time0, process_init_time1]
        dispatcher.step
        expect(dispatcher.queue_unit.queues[0]).to include(process_init_time0)
        expect(dispatcher.queue_unit.queues[1]).to_not include(process_init_time1)
      end

      it "discards process bigger than memory" do
        dispatcher.processes = [big_process_init_time0, process_init_time0]
        dispatcher.step
        expect(dispatcher.queue_unit.queues[0]).to_not include(big_process_init_time0)
        expect(dispatcher.queue_unit.queues[0]).to include(process_init_time0)
        expect(dispatcher.processes).to_not include(big_process_init_time0)
        expect(dispatcher.processes).to include(process_init_time0)
        expect(dispatcher.discarded_processes).to include([MemoryUnit::ProcessTooBigError, big_process_init_time0])
      end
    end
  end

  describe "#execute_instruction" do
    it "calls the :write method correctly" do
      expect(dispatcher.disk_unit).to receive(:write_file).with("Z", 2)
      dispatcher.execute_instruction([:write_file, "Z", 2])
    end

    it "calls the :delete method correctly" do
      expect(dispatcher.disk_unit).to receive(:delete_file).with("Z")
      dispatcher.execute_instruction([:delete_file, "Z"])
    end

    it "calls the :default_instruction method correctly" do
      expect(dispatcher).to receive(:default_instruction)
      dispatcher.execute_instruction(:default)
    end
  end

  describe "#alocate" do
    let(:dispatcher) { Dispatcher.new }
    let(:process) { ProcessUnit.new(1, 2, 0, 7, 64, 1, 0, 0, 0) }

    it "alocates memory and devices" do
      dispatcher.alocate(process)
      expect(dispatcher.memory_unit.alocated(process)).to be_truthy
      expect(dispatcher.io_resource_unit.devices_alocated?(process.id, process.devices)).to be_truthy
    end

    context "when failing either memory or device alocation" do
      it "fails if only memory fails" do
        allow(dispatcher.memory_unit).to receive(:alocate).and_return(nil)
        allow(dispatcher.io_resource_unit).to receive(:alocate_devices).and_return(true)

        expect(dispatcher.alocate(process)).to be_falsey
      end

      it "fails if only devices fails" do
        allow(dispatcher.memory_unit).to receive(:alocate).and_return(true)
        allow(dispatcher.io_resource_unit).to receive(:alocate_devices).and_return(false)

        expect(dispatcher.alocate(process)).to be_falsey
      end

      it "fails if both fails" do
        allow(dispatcher.memory_unit).to receive(:alocate).and_return(false)
        allow(dispatcher.io_resource_unit).to receive(:alocate_devices).and_return(false)

        expect(dispatcher.alocate(process)).to be_falsey
      end

      it "does not alocate memory if device fails" do
        allow(dispatcher.io_resource_unit).to receive(:alocate_devices).and_return(false)
        dispatcher.alocate(process)
        expect(dispatcher.memory_unit.alocated(process)).to be_falsey
        expect(dispatcher.io_resource_unit.devices_alocated?(process.id, process.devices)).to be_falsey
      end

      it "does not device memory if memory fails" do
        allow(dispatcher.memory_unit).to receive(:alocate).and_return(false)
        dispatcher.alocate(process)
        expect(dispatcher.memory_unit.alocated(process)).to be_falsey
        expect(dispatcher.io_resource_unit.devices_alocated?(process.id, process.devices)).to be_falsey
      end
    end
  end

  describe "#load_processes" do
    let(:first_process) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }
    let(:last_process) { ProcessUnit.new(2, 3, 1, 2, 64, 0, 0, 1, 0) }

    it "loads correctly" do
      subject.load_processes(fixture_file("processes.txt"))

      expect(dispatcher.processes.size).to eq 3
      expect(dispatcher.processes).to all(be_a(ProcessUnit))
      expect(dispatcher.processes.first).to have_attributes first_process.attributes
      expect(dispatcher.processes.last).to have_attributes last_process.attributes
    end
  end

  describe "#load_files_data" do
    it "loads correctly" do
      subject.load_files_data(fixture_file("files_diskdata.txt"))
      expect(subject.disk_unit.size).to eq 10
      expect(subject.disk_unit.written_blocks).to eq 4
    end

    it "adds the instructions to the processes" do
      process0 = ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0)
      subject.processes << process0
      subject.load_files_data(fixture_file("files_instructions.txt"))
      expect(process0.instructions).to include([:write_file, "B", 2], [:delete_file, "A"])
    end
  end
end
