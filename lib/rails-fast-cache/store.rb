# frozen_string_literal: true

require 'active_job'
require 'active_support'
require 'active_support/core_ext'

require_relative 'brotli_compressor'
require_relative 'write_job'
require_relative 'write_multi_job'

module RailsFastCache
  class Store < ::ActiveSupport::Cache::Store
    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
      max_queue: 100,
      fallback_policy: :caller_runs
    }.freeze

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
      :key_matcher,
      :mute,
      :new,
      :read,
      :read_multi,
      :silence!,
      to: :@store
    )

    def self.supports_cache_versioning?
      true
    end

    def initialize(cache_store, *parameters)
      options = parameters.extract_options!
      options[:compressor] ||= RailsFastCache::BrotliCompressor if !options.key?(:coder) && cache_store != :memory_store
      options[:serializer] ||= :message_pack unless options.key?(:coder)

      @queue = ActiveJob::QueueAdapters::AsyncAdapter.new(
        **DEFAULT_EXECUTOR_OPTIONS.merge(*options.delete(:executor))
      )
      @store = ActiveSupport::Cache.lookup_store(cache_store, *parameters, **options)
    end

    def write(name, value, options = nil)
      @queue.enqueue(WriteJob.perform_later(@store, name, value, options))
    end

    def write_multi(hash, options = nil)
      @queue.enqueue(WriteMultiJob.perform_later(@store, hash, options))
    end

    def shutdown(wait: true)
      @queue.shutdown(wait:)
    end
  end
end
