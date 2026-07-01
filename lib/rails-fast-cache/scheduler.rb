# frozen_string_literal: true

require 'concurrent'

module RailsFastCache
  class Scheduler
    EXECUTOR_OPTIONS = {
      min_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_queue: ENV.fetch('RAILS_FAST_CACHE_MAX_QUEUE', 100).to_i,
      fallback_policy: :caller_runs
    }.freeze

    def initialize
      @executor = Concurrent::ThreadPoolExecutor.new(**EXECUTOR_OPTIONS)
      @inflight = Concurrent::AtomicFixnum.new(0)
      @idle = Concurrent::Event.new
      @idle.set
    end

    def post(&block)
      @inflight.increment
      @idle.reset
      @executor.post do
        block.call
      ensure
        @idle.set if @inflight.decrement.zero?
      end
    end

    def flush(timeout = nil)
      @idle.wait(timeout)
    end

    def shutdown(wait: true)
      @executor.shutdown
      @executor.wait_for_termination if wait
    end
  end
end
