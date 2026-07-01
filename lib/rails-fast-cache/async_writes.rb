# frozen_string_literal: true

module RailsFastCache
  module AsyncWrites
    attr_accessor :rails_fast_cache_scheduler, :rails_fast_cache_logger

    def write(name, value, options = nil)
      rails_fast_cache_scheduler.post { perform_async_write { super(name, value, options) } }
      true
    end

    def write_multi(hash, options = nil)
      rails_fast_cache_scheduler.post { perform_async_write { super(hash, options) } }
      true
    end

    private

    def perform_async_write
      yield
    rescue StandardError => e
      rails_fast_cache_logger&.error("[rails-fast-cache] async write failed: #{e.class}: #{e.message}")
      nil
    end
  end
end
