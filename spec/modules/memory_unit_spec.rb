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

  let(:real_time_process) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }
  let(:user_process) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }

  subject(:memory_unit) { MemoryUnit.new }

  it { is_expected.to have_attributes attributes }

  describe "#alocate" do
    context "when real time process" do
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

  describe "#dealocate" do
    it "removes a process from memory" do
      expect {
        memory_unit.alocate(user_process)
        expect(memory_unit.alocated(user_process)).to eq 0
        memory_unit.dealocate(user_process)
        expect(memory_unit.alocated(user_process)).to eq nil
      }.to_not change(memory_unit, :size)
    end

    it "returns true if process was not alocated" do
      expect(memory_unit.dealocate(user_process)).to eq true
    end
  end

  describe "#alocated" do
    it "returns true if process already in memory" do
      expect(memory_unit.alocated(user_process)).to eq nil
      memory_unit.alocate(user_process)
      expect(memory_unit.alocated(user_process)).to eq 0
    end
  end

  describe "#test" do
    it "raises an error when big real time process" do
      big_process = ProcessUnit.new(0, 2, 0, 7, 65, 1, 0, 0, 0)
      expect { memory_unit.test(big_process) }.to raise_error(MemoryUnit::ProcessTooBigError)
    end

    it "raises an error when big user process " do
      big_process = ProcessUnit.new(1, 2, 0, 7, 961, 1, 0, 0, 0)
      expect { memory_unit.test(big_process) }.to raise_error(MemoryUnit::ProcessTooBigError)
    end
  end

  describe "#written_blocks" do
    it "returns correctly" do
      memory_unit = MemoryUnit.new(Concurrent::Array.new(64), written_user_memory)
      expect(memory_unit.written_blocks).to eq 24
    end
  end
end
