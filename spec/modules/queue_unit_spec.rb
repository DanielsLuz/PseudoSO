describe QueueUnit do
  let(:attributes) {
    {
      real_time_queue: an_instance_of(QueueUnit::PriorityQueue)
    }
  }

  subject(:queue_unit) { QueueUnit.new }

  it { is_expected.to have_attributes attributes }

  describe "#push" do
    [0, 1, 2, 3].each do |priority|
      context "when given a priority #{priority} process" do
        let(:process) { ProcessUnit.new(0, 2, priority, 7, 64, 1, 0, 0, 0) }
        it "pushes to the correct queue" do
          queue_unit.push(process)
          expect(queue_unit.queues[priority]).to include process
        end

        it "returns nil when queue is full" do
          allow_any_instance_of(QueueUnit::PriorityQueue).to receive(:full?).and_return(true)
          expect(queue_unit.push(process)).to eq nil
        end
      end
    end
  end

  describe "#pop" do
    let(:process_priority_0) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }
    let(:process_priority_1) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }
    it "returns the lowest priority process" do
      queue_unit.push(process_priority_1)
      queue_unit.push(process_priority_0)
      expect(queue_unit.pop).to eq process_priority_0
      expect(queue_unit.queues[0]).to_not include process_priority_0
    end

    it "returns nil if queues empty" do
      expect(queue_unit.pop).to eq nil
    end
  end

  describe QueueUnit::PriorityQueue do
    subject { QueueUnit::PriorityQueue.new 0 }

    it { is_expected.to have_attributes max_size: 1000, queue: an_instance_of(Concurrent::Array) }

    describe "#push" do
      let(:process0) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }
      it "puts the process in the queue" do
        subject.push(process0)
        expect(subject.queue).to include process0
      end

      context "when queue is full" do
        it "returns nil" do
          real_time_queue = QueueUnit::PriorityQueue.new 0, 0
          expect(real_time_queue.push(process0)).to eq nil
          expect(real_time_queue.queue).to_not include process0
        end
      end
    end

    describe "#pop" do
      let(:process0) { ProcessUnit.new(0, 2, 0, 7, 64, 1, 0, 0, 0) }
      it "returns the first process" do
        subject.push(process0)
        expect(subject.queue.first).to eq process0
        expect(subject.pop).to eq process0
        expect(subject.queue).to be_empty
      end
    end
  end
end
