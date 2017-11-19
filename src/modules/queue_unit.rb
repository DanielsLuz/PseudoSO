class QueueUnit
  class PriorityQueue
    attr_reader :priority, :max_size, :queue

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

    def full?
      @queue.size == @max_size
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

  def real_time_queue
    @queues[0]
  end
end
