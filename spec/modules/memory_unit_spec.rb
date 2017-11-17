describe MemoryUnit do
  let(:written_user_memory) {
    user_memory = Concurrent::Array.new(960)
    user_memory[0, 24] = Concurrent::Array.new(24, "A")
    user_memory
  }

  let(:attributes) {
    {
      size: 1024
    }
  }

  subject(:memory_unit) { MemoryUnit.new }

  it { is_expected.to have_attributes attributes }

  describe ".alocate" do
    let(:process0) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }

    it "alocates correctly" do
      expect(memory_unit.alocate(process0)).to eq 0
      expect(memory_unit.written_blocks).to eq process0.memory_blocks
    end

    context "when initial blocks written" do
      it "writes with offset" do
        memory_unit = MemoryUnit.new(Concurrent::Array.new(64), written_user_memory)
        expect(memory_unit.alocate(process0)).to eq 24
        expect(memory_unit.written_blocks).to eq 88
      end
    end
  end

  describe ".written_blocks" do
    it "returns correctly" do
      memory_unit = MemoryUnit.new(Concurrent::Array.new(64), written_user_memory)
      expect(memory_unit.written_blocks).to eq 24
    end
  end
end
