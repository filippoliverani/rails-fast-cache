# frozen_string_literal: true

require 'spec_helper'

describe RailsFastCache::Store do
  let(:value) do
    {
      time: Time.now,
      string: SecureRandom.hex(2048)
    }
  end

  def self.test_write(cache_store)
    describe '#write' do
      it "stores value in #{cache_store}" do
        store = initialize_store(cache_store)

        store.write('store_spec_key', value)
        store.shutdown

        expect(store.read('store_spec_key')).to eq(value)
      end
    end

    describe '#write_multi' do
      it "stores value in #{cache_store}" do
        store = initialize_store(cache_store)
        values = {
          'store_spec_key_1' => value,
          'store_spec_key_2' => value
        }

        store.write_multi(values)
        store.shutdown

        expect(store.read_multi('store_spec_key_1', 'store_spec_key_2')).to eq(values)
      end
    end
  end

  [
    :memory_store,
    [:file_store, 'tmp/cache/'],
    :redis_cache_store
  ].each do |cache_store|
    test_write(cache_store)
  end

  describe '#options' do
    it 'reflects options passed to the underlying cache store' do
      store = RailsFastCache::Store.new(:memory_store, expires_in: 42)

      expect(store.options[:expires_in]).to eq(42)
    end
  end

  describe '#silence?' do
    it 'reflects the underlying cache store mute state' do
      store = RailsFastCache::Store.new(:memory_store)

      store.mute { expect(store.silence?).to be true }
      expect(store.silence?).to be_falsy
    end
  end

  describe '#namespace' do
    it 'reflects the namespace passed to the underlying cache store' do
      store = RailsFastCache::Store.new(:memory_store, namespace: 'test_ns')

      expect(store.namespace).to eq('test_ns')
    end
  end

  describe '#read_counter and #write_counter' do
    it 'delegates counter operations to the underlying cache store' do
      store = RailsFastCache::Store.new(:memory_store)
      store.write_counter('store_spec_counter', 1)
      store.flush

      expect(store.read_counter('store_spec_counter')).to eq(1)
    end
  end

  def initialize_store(cache_store)
    store = RailsFastCache::Store.new(*cache_store)
    store.delete_matched('store_spec_*')
    store
  end
end

  describe '#flush' do
    it 'drains pending async writes without shutting down the pool' do
      store = RailsFastCache::Store.new(:memory_store)
      store.write('flush_key', 'flush_value')
      store.flush
      expect(store.read('flush_key')).to eq('flush_value')
      # pool still alive: a subsequent write works
      store.write('flush_key2', 'v2')
      store.flush
      expect(store.read('flush_key2')).to eq('v2')
      store.shutdown
    end
  end

  describe '#fetch' do
    it 'returns the block value synchronously even though the cache write is deferred' do
      store = RailsFastCache::Store.new(:memory_store)
      result = store.fetch('fetch_key') { 'computed' }
      expect(result).to eq('computed')
      store.shutdown
    end

    it 'populates the cache asynchronously on a miss (value present after flush)' do
      store = RailsFastCache::Store.new(:memory_store)
      store.fetch('async_fetch_key') { 'fetched_value' }
      expect(store.read('async_fetch_key')).to be_nil.or eq('fetched_value')
      store.flush
      expect(store.read('async_fetch_key')).to eq('fetched_value')
      store.shutdown
    end

    it 'does not re-execute the block on a cache hit' do
      store = RailsFastCache::Store.new(:memory_store)
      store.fetch('hit_key') { 'original' }
      store.flush
      calls = 0
      store.fetch('hit_key') { calls += 1; 'new' }
      expect(calls).to eq(0)
      store.shutdown
    end
  end

  describe '#supports_cache_versioning?' do
    it 'returns true' do
      expect(RailsFastCache::Store.supports_cache_versioning?).to be(true)
    end
  end

  describe 'per-instance isolation' do
    it 'each Store owns an independent scheduler (shutdown of one does not affect the other)' do
      store_a = RailsFastCache::Store.new(:memory_store)
      store_b = RailsFastCache::Store.new(:memory_store)
      store_a.write('iso_key', 'iso_value')
      store_a.shutdown
      # store_b's pool is unaffected
      store_b.write('iso_key2', 'iso_value2')
      store_b.shutdown
      expect(store_b.read('iso_key2')).to eq('iso_value2')
    end
  end

