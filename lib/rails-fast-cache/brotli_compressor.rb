# frozen_string_literal: true

require 'brotli'

module RailsFastCache
  module BrotliCompressor
    COMPRESSION_PREFIX = "\x02".b
    ZLIB_COMPRESSION_PREFIX = "\x78".b
    COMPRESSION_QUALITY = 3

    def self.deflate(dumped)
      COMPRESSION_PREFIX +
        ::Brotli.deflate(dumped, quality: COMPRESSION_QUALITY)
    end

    def self.inflate(compressed)
      if compressed.start_with?(COMPRESSION_PREFIX)
        ::Brotli.inflate(compressed.byteslice(1..-1))
      elsif compressed.start_with?(ZLIB_COMPRESSION_PREFIX)
        ::Zlib.inflate(compressed)
      else
        compressed
      end
    end
  end
end
