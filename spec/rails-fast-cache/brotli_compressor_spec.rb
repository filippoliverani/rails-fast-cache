# frozen_string_literal: true

require 'spec_helper'

describe RailsFastCache::BrotliCompressor do
  describe '#deflate' do
    it 'compresses payload with Brotli' do
      deflated = described_class.deflate('test')

      expect(deflated).to start_with("\x02")
    end
  end

  describe '#inflate' do
    it 'decompresses payload with Brotli' do
      inflated = described_class.inflate(described_class.deflate('test'))

      expect(inflated).to eq('test')
    end
  end
end
