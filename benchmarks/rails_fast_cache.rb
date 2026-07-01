#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../lib/rails-fast-cache'

CACHE_PREFIX_DEFAULT = 'rfc_bench_default'
CACHE_PREFIX_FAST = 'rfc_bench_fast'
CACHE_KEYS_DEFAULT = 100.times.map { |i| "#{CACHE_PREFIX_DEFAULT}_#{i}" }
CACHE_KEYS_FAST = 100.times.map { |i| "#{CACHE_PREFIX_FAST}_#{i}" }

ActiveSupport::Cache.format_version = 7.1

data = {
  time: Time.now,
  string: SecureRandom.hex(2048)
}

puts 'Seeding read benchmark data...'

default_read_store = ActiveSupport::Cache::RedisCacheStore.new
CACHE_KEYS_DEFAULT.each { |k| default_read_store.write(k, data) }

fast_read_store = RailsFastCache::Store.new(:redis_cache_store)
CACHE_KEYS_FAST.each { |k| fast_read_store.write(k, data) }
fast_read_store.flush

puts 'Ready.'

Benchmark.ips do |x|
  x.report('default_cache_read') do
    CACHE_KEYS_DEFAULT.each { |k| default_read_store.read(k) }
  end

  x.report('rails_fast_cache_read') do
    CACHE_KEYS_FAST.each { |k| fast_read_store.read(k) }
  end

  x.compare!
end

default_write_store = ActiveSupport::Cache::RedisCacheStore.new
fast_write_store = RailsFastCache::Store.new(:redis_cache_store)

Benchmark.ips do |x|
  x.report('default_cache_write') do
    CACHE_KEYS_DEFAULT.each { |k| default_write_store.write(k, data) }
  end

  x.report('rails_fast_cache_write') do
    CACHE_KEYS_FAST.each { |k| fast_write_store.write(k, data) }
    fast_write_store.flush
  end

  x.compare!
end

fast_read_store.shutdown
fast_write_store.shutdown
