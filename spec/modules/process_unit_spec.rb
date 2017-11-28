describe ProcessUnit do
  let(:attributes) {
    {
      id:             0,
      init_time:      2,
      priority:       0,
      processor_time: 7,
      memory_blocks:  64,
      printer:        1,
      scanner:        0,
      modem:          0,
      num_code_disk:  0,
      instructions:   Concurrent::Array.new(7, :default)
    }
  }

  subject { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }

  it { is_expected.to be_a ProcessUnit }
  it { is_expected.to have_attributes attributes }

  describe "#user_process?" do
    [1, 2, 3].each do |priority|
      it "returns true when priority is #{priority}" do
        process = ProcessUnit.new(0, 2, priority, 7, 64, 1, 0, 0, 0)
        expect(process).to be_a_user_process
      end
    end
  end

  describe "#real_time_process?" do
    let(:priority) { 0 }
    it "returns true when priority is 0" do
      process = ProcessUnit.new(0, 2, priority, 7, 64, 1, 0, 0, 0)
      expect(process).to be_a_real_time_process
    end
  end

  describe "#step" do
    it "returns the next instruction" do
      subject.instructions = [[:default], [:write, "A", 2], [:delete, "A"]]
      expect(subject.step).to eq [:default]
      expect(subject.step).to eq [:write, "A", 2]
      expect(subject.step).to eq [:delete, "A"]
      expect(subject.step).to eq nil
    end
  end

  describe "#finished?" do
    it "returns true if next instruction is nil" do
      subject.instructions = [[:default]]
      subject.step
      expect(subject).to be_finished
    end
  end

  describe "#replace_default_instruction" do
    context "when #write instruction" do
      it "parses correctly" do
        subject.replace_default_instruction("0", "B", "2")
        expect(subject.instructions).to include([:write_file, "B", 2])
      end
    end

    context "when #delete instruction" do
      it "parses correctly" do
        subject.replace_default_instruction("1", "A", nil)
        expect(subject.instructions).to include([:delete_file, "A"])
      end
    end
  end
end
