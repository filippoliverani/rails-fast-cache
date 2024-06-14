# frozen_string_literal: true

module RailsFastCache
  class Scheduler
    EXECUTOR_OPTIONS = {
      min_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_queue: 100,
      fallback_policy: :caller_runs
    }.freeze

    def self.queue_adapter
      @queue_adapter ||= ActiveJob::QueueAdapters::AsyncAdapter.new(**EXECUTOR_OPTIONS)
    end

    def self.shutdown
      @queue_adapter&.shutdown(wait: true)
    end
  end
end
