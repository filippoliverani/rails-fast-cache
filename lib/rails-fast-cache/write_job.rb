# frozen_string_literal: true

require_relative 'non_serializing_job'

module RailsFastCache
  class WriteJob < NonSerializingJob
    def perform(name, value, options)
      Scheduler.store.write(name, value, options)
    end
  end
end
