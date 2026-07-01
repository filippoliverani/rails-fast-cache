# frozen_string_literal: true

require 'spec_helper'

describe RailsFastCache::AsyncWrites do
  let(:logger) { instance_double('Logger', error: nil) }

  def build_store(cache_store_sym = :memory_store)
    RailsFastCache::Store.new(cache_store_sym)
  end

  describe '#write' do
    it 'returns true immediately without waiting for the write to complete' do
      store = build_store
      result = nil
      expect {
        result = store.write('key', 'value')
      }.not_to raise_error
      expect(result).to be(true)
      store.shutdown
    end

    it 'makes the value available after flush' do
      store = build_store
      store.write('async_key', 'async_value')
      store.flush
      expect(store.read('async_key')).to eq('async_value')
      store.shutdown
    end

    it 'does not recurse into the async wrapper (inner write called exactly once)' do
      store = build_store
      inner = store.instance_variable_get(:@cache_store)
      call_count = 0
      original_write_entry = inner.method(:write_entry)
      allow(inner).to receive(:write_entry) do |*args, **kwargs|
        call_count += 1
        original_write_entry.call(*args, **kwargs)
      end
      store.write('recurse_key', 'value')
      store.flush
      expect(call_count).to eq(1)
      store.shutdown
    end

    it 'logs an error on failure but does not raise' do
      store = build_store
      inner = store.instance_variable_get(:@cache_store)
      inner.rails_fast_cache_logger = logger
      allow(inner).to receive(:write_entry).and_raise('boom')
      expect { store.write('fail_key', 'value') }.not_to raise_error
      store.flush
      expect(logger).to have_received(:error).with(a_string_including('boom'))
      store.shutdown
    end
  end

  describe '#write_multi' do
    it 'returns the hash immediately without waiting for the write to complete' do
      store = build_store
      hash = { 'k1' => 'v1', 'k2' => 'v2' }
      result = store.write_multi(hash)
      expect(result).to be_truthy
      store.shutdown
    end

    it 'makes all values available after flush' do
      store = build_store
      store.write_multi('mk1' => 'mv1', 'mk2' => 'mv2')
      store.flush
      expect(store.read('mk1')).to eq('mv1')
      expect(store.read('mk2')).to eq('mv2')
      store.shutdown
    end
  end
end
