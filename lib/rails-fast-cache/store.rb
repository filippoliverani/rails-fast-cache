# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative 'async_writes'
require_relative 'brotli_compressor'
require_relative 'scheduler'

module RailsFastCache
  class Store < ::ActiveSupport::Cache::Store
    delegate(
      :cleanup,
      :clear,
      :decrement,
      :delete,
      :delete_matched,
      :delete_multi,
      :exist?,
      :fetch,
      :fetch_multi,
      :increment,
      :mute,
      :namespace,
      :namespace=,
      :options,
      :read,
      :read_counter,
      :read_multi,
      :silence,
      :silence!,
      :silence?,
      :write,
      :write_counter,
      :write_multi,
      to: :@cache_store
    )
    delegate_missing_to :@cache_store

    def self.supports_cache_versioning?
      true
    end

    def initialize(cache_store, *parameters)
      options = parameters.extract_options!
      options[:compressor] ||= RailsFastCache::BrotliCompressor if !options.key?(:coder) && cache_store != :memory_store
      options[:serializer] ||= :message_pack unless options.key?(:coder)

      @cache_store = ActiveSupport::Cache.lookup_store(cache_store, *parameters, **options)
      @scheduler = RailsFastCache::Scheduler.new

      unless @cache_store.singleton_class.include?(RailsFastCache::AsyncWrites)
        @cache_store.singleton_class.prepend(RailsFastCache::AsyncWrites)
      end
      @cache_store.rails_fast_cache_scheduler = @scheduler
      @cache_store.rails_fast_cache_logger = @cache_store.logger
    end

    def flush(timeout = nil)
      @scheduler.flush(timeout)
    end

    def shutdown
      @scheduler.shutdown(wait: true)
    end

    def write_serialized_entry(...)
      @cache_store.send(:write_serialized_entry)
    end

    def read_serialized_entry(...)
      @cache_store.send(:read_serialized_entry)
    end
  end
end
