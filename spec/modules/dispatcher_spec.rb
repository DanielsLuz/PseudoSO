describe Dispatcher do
  subject(:dispatcher) { Dispatcher.new }

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
      expect(process0.instructions).to include("0, B, 2", "1, A, 0")
    end
  end
end
