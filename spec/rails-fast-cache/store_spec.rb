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

  def initialize_store(cache_store)
    store = RailsFastCache::Store.new(*cache_store)
    store.delete_matched('store_spec_*')
    store
  end
end
