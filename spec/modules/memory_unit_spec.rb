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

  describe "#alocate" do
    context "when user process" do
      let(:user_process) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }

      it "alocates correctly" do
        expect(memory_unit.alocate(user_process)).to eq 0
        expect(memory_unit.written_blocks).to eq user_process.memory_blocks
      end

      context "when initial blocks written" do
        it "writes with offset" do
          memory_unit = MemoryUnit.new(Concurrent::Array.new(64), written_user_memory)
          expect(memory_unit.alocate(user_process)).to eq 24
          expect(memory_unit.written_blocks).to eq 88
        end
      end
    end
  end

  describe "#written_blocks" do
    it "returns correctly" do
      memory_unit = MemoryUnit.new(Concurrent::Array.new(64), written_user_memory)
      expect(memory_unit.written_blocks).to eq 24
    end
  end
end
