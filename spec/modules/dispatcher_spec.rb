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

    context "when escalonating" do
      let(:process_init_time0) { ProcessUnit.new(0, 0, 0, 7, 64, 1, 0, 0, 0) }
      it "pushes processes that start at that processor time" do
        dispatcher.processes = [process_init_time0, process_init_time1]
        dispatcher.step
        expect(dispatcher.queue_unit.queues[0]).to include(process_init_time0)
        expect(dispatcher.queue_unit.queues[1]).to_not include(process_init_time1)
      end
    end
  end

  describe "#alocated_adress" do
    let(:dispatcher) { Dispatcher.new }

    it "does not alocate if it is too big" do
      process1 = ProcessUnit.new(0, 2, 0, 7, 1000, 1, 0, 0, 0)
      expect(dispatcher.alocated_adress(process1)).to eq nil
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
      expect(process0.instructions).to include([:write, "B", 2], [:delete, "A"])
    end
  end
end
