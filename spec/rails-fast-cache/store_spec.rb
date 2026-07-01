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

      expect(store.read_counter('store_spec_counter')).to eq(1)
    end
  end

  def initialize_store(cache_store)
    store = RailsFastCache::Store.new(*cache_store)
    store.delete_matched('store_spec_*')
    store
  end
end
