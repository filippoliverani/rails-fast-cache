# frozen_string_literal: true

require_relative 'non_serializing_job'

module RailsFastCache
  class WriteMultiJob < NonSerializingJob
    def perform(hash, options)
      Scheduler.store.write_multi(hash, options)
    end
  end
end
