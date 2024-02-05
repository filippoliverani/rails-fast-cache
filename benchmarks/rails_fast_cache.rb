#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark/ips'
require 'ostruct'
require_relative '../lib/rails-fast-cache'

CACHE_PREFIX = 'rails_fast_cache_benchmark'

ActiveSupport::Cache.format_version = 7.1

data = {
  time: Time.now,
  string: SecureRandom.hex(2048)
}

def initialize_store_data(store, data)
  store.delete_matched("#{CACHE_PREFIX}*")
  10.times do |i|
    store.write("#{CACHE_PREFIX}_#{i}", data)
  end
  sleep 1
end

Benchmark.ips do |x|
  x.report('default_cache_read') do
    store = ActiveSupport::Cache::RedisCacheStore.new
    initialize_store_data(store, data)

    100.times do |i|
      store.read("#{CACHE_PREFIX}_#{i}")
    end
  end

  x.report('rails_fast_cache_read') do
    store = RailsFastCache::Store.new(:redis_cache_store)
    initialize_store_data(store, data)

    100.times do |i|
      store.read("#{CACHE_PREFIX}_#{i}")
    end
  end

  x.compare!
end

Benchmark.ips do |x|
  x.report('default_cache_write') do
    store = ActiveSupport::Cache::RedisCacheStore.new

    100.times do |i|
      store.write("#{CACHE_PREFIX}_#{i}", data)
    end
  end

  x.report('rails_fast_cache_write') do
    store = RailsFastCache::Store.new(:redis_cache_store)

    100.times do |i|
      store.write("#{CACHE_PREFIX}_#{i}", data)
    end
  end

  x.compare!
end
