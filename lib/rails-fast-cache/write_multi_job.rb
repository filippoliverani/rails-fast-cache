# frozen_string_literal: true

require_relative 'non_serializing_job'

module RailsFastCache
  class WriteMultiJob < NonSerializingJob
    def perform(cache_store, hash, options)
      cache_store.write_multi(hash, options)
    end
  end
end
