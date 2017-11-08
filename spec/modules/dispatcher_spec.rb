describe Dispatcher do
  subject(:dispatcher) { Dispatcher.new }

  describe "#load_processes" do
    let(:first_process) { ProcessUnit.new(2, 0, 7, 64, 1, 0, 0, 0) }
    let(:last_process) { ProcessUnit.new(3, 1, 2, 64, 0, 0, 1, 0) }

    it "loads all the processes" do
      subject.load_processes(fixture_file("processes.txt"))

      expect(dispatcher.processes.size).to eq 3
      expect(dispatcher.processes).to all(be_a(ProcessUnit))
      expect(dispatcher.processes.first).to have_attributes first_process.attributes
      expect(dispatcher.processes.last).to have_attributes last_process.attributes
    end
  end
end
