class QueueUnit
  class PriorityQueue
    attr_reader :priority, :max_size, :queue
    alias processes queue

    def initialize(priority, max_size=1000)
      @max_size = max_size
      @queue = Concurrent::Array.new
      @priority = priority
    end

    def push(process)
      return if full?
      @queue << process
    end

    def pop
      @queue.pop
    end

    def delete(process)
      @queue.delete(process)
    end

    def full?
      @queue.size == @max_size
    end

    def empty?
      @queue.empty?
    end

    def include?(process)
      @queue.include?(process)
    end

    def size
      @queue.size
    end
  end

  PRIORITIES = [0, 1, 2, 3].freeze

  attr_reader :queues

  def initialize
    @queues = {}
    PRIORITIES.each do |priority|
      @queues[priority] = PriorityQueue.new(priority)
    end
  end

  def push_batch(process_array)
    process_array.each {|process| push(process) }
  end

  def push(process)
    @queues[process.priority].push(process)
  end

  def pop
    process = nil
    @queues.each do |_priority, queue|
      process = queue.pop
      break if process
    end
    process
  end

  def age_queues
    @queues.each do |priority, priority_queue|
      next if priority <= 1
      age_processes(priority_queue)
    end
  end

  def age_processes(queue)
    queue.processes.each do |process|
      break unless age process
    end
  end

  def age(process)
    return unless can_age?(process)
    @queues[process.priority - 1].push(@queues[process.priority].delete(process))
  end

  def can_age?(process)
    process.priority > 1 && !@queues[process.priority - 1].full?
  end

  def real_time_queue
    @queues[0]
  end
end
