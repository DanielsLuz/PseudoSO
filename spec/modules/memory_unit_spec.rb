describe MemoryUnit do
  let(:attributes) {
    {
      size: 1024
    }
  }

  let(:written_user_memory) {
    user_memory = Concurrent::Array.new(960)
    user_memory[0, 24] = Concurrent::Array.new(24, "A")
    user_memory
  }

  subject(:memory_unit) { MemoryUnit.new }

  it { is_expected.to have_attributes attributes }

  describe "#alocate" do
    context "when real time process" do
      let(:real_time_process) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }

      it "alocates correctly" do
        expect(memory_unit.alocate(real_time_process)).to eq 0
        expect(memory_unit.written_blocks).to eq real_time_process.memory_blocks
      end

      it "does not alocate if bigger than memory" do
        big_process = ProcessUnit.new(0, 2, 0, 7, 65, 1, 0, 0, 0)
        expect {
          memory_unit.alocate(big_process)
        }.to_not(change { memory_unit.written_blocks })
      end
    end

    context "when user process" do
      let(:user_process) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }

      it "alocates correctly" do
        expect(memory_unit.alocate(user_process)).to eq 0
        expect(memory_unit.written_blocks).to eq user_process.memory_blocks
      end

      it "does not alocate if bigger than memory" do
        big_process = ProcessUnit.new(0, 2, 1, 7, 961, 1, 0, 0, 0)
        expect {
          memory_unit.alocate(big_process)
        }.to_not(change { memory_unit.written_blocks })
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
