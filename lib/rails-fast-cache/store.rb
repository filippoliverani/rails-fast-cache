# frozen_string_literal: true

require 'active_job'
require 'active_support'
require 'active_support/core_ext'

require_relative 'brotli_compressor'
require_relative 'scheduler'
require_relative 'write_job'
require_relative 'write_multi_job'

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
      :key_matcher,
      :mute,
      :new,
      :read,
      :read_multi,
      :silence!,
      to: :@cache_store
    )
    delegate_missing_to :@cache_store

    cattr_accessor :cache_store

    def self.supports_cache_versioning?
      true
    end

    def self.shutdown
      RailsFastCache::Scheduler.shutdown
    end

    def initialize(cache_store, *parameters)
      options = parameters.extract_options!
      options[:compressor] ||= RailsFastCache::BrotliCompressor if !options.key?(:coder) && cache_store != :memory_store
      options[:serializer] ||= :message_pack unless options.key?(:coder)

      @cache_store = ActiveSupport::Cache.lookup_store(cache_store, *parameters, **options)
      self.class.cache_store = @cache_store
    end

    def write(name, value, options = nil)
      WriteJob.perform_later(@cache_store, name, value, options)
      true
    end

    def write_multi(hash, options = nil)
      WriteMultiJob.perform_later(@cache_store, hash, options)
      true
    end

    def shutdown
      self.class.shutdown
    end
  end
end
