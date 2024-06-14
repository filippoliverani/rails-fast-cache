# frozen_string_literal: true

require 'active_job'
require_relative 'scheduler'

module RailsFastCache
  class NonSerializingJob < ::ActiveJob::Base
    self.logger = nil
    self.log_arguments = false
    self.queue_adapter = RailsFastCache::Scheduler.queue_adapter

    def deserialize_arguments(serialized_arguments)
      serialized_arguments
    end

    def serialize_arguments(arguments)
      arguments
    end
  end
end
