# frozen_string_literal: true

require_relative 'non_serializing_job'

module RailsFastCache
  class WriteJob < NonSerializingJob
    def perform(store, name, value, options)
      store.write(name, value, options)
    end
  end
end
