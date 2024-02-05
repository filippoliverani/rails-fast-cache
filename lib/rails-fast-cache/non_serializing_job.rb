# frozen_string_literal: true

require 'active_job'

module RailsFastCache
  class NonSerializingJob < ::ActiveJob::Base
    self.logger = nil

    def deserialize_arguments(serialized_arguments)
      serialized_arguments
    end

    def serialize_arguments(arguments)
      arguments
    end
  end
end
