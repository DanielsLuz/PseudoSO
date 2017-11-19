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

  describe "#age_queues" do
    let(:process_priority_1) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }
    let(:process_priority_2) { ProcessUnit.new(0, 2, 2, 7, 64, 1, 0, 0, 0) }
    let(:process_priority_3) { ProcessUnit.new(0, 2, 3, 7, 64, 1, 0, 0, 0) }
    it "ages all queues" do
      subject.push(process_priority_1)
      subject.push(process_priority_2)
      subject.push(process_priority_3)
      subject.age_queues
      expect(subject.queues[1]).to include(process_priority_1, process_priority_2)
      expect(subject.queues[2]).to include(process_priority_3)
      expect(subject.queues[3]).to be_empty
    end
  end

  describe "#age" do
    let(:process_priority_1) { ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0) }
    let(:process_priority_2) { ProcessUnit.new(0, 2, 2, 7, 64, 1, 0, 0, 0) }
    it "moves process to higher priorities" do
      subject.push(process_priority_2)
      subject.age(process_priority_2)
      expect(subject.queues[1]).to include process_priority_2
      expect(subject.queues[2]).to_not include process_priority_2
    end

    it "does not move priority 1 process" do
      subject.push(process_priority_1)
      subject.age(process_priority_1)
      expect(subject.queues[1]).to include process_priority_1
    end
  end

  describe "can_age?" do
    it "returns true if higher priority queue has space" do
      expect(queue_unit.queues[1]).to receive(:full?).and_return(false)
      process_priority2 = ProcessUnit.new(0, 2, 2, 7, 64, 1, 0, 0, 0)
      expect(queue_unit.can_age?(process_priority2)).to eq true
    end

    it "returns false if priority lesser than 1" do
      process_priority1 = ProcessUnit.new(0, 2, 1, 7, 64, 1, 0, 0, 0)
      expect(queue_unit.can_age?(process_priority1)).to eq false
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
