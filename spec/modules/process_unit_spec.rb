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

  describe ".step" do
    it "returns the next instruction" do
      subject.instructions = [:default, :write, :delete]
      expect(subject.step).to eq :default
      expect(subject.step).to eq :write
      expect(subject.step).to eq :delete
      expect(subject.step).to eq nil
    end
  end
end
