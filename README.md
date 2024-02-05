# Rails Fast Cache

This gem provides a wrapper around Rails cache store that improves performance by:
- using Brotli as default compressor instead of GZip
- using MessagePack as default serializer instead of Marshal
- delegating cache writes to a thread pool instead of running them synchronously

## Requirements
- Rails 7.1+
- You need to provide appropriate MessagePack serializers to cache custom classes

## Installation

`Gemfile`

```ruby
gem 'rails-fast-cache'
```

## Configuration

Rail Fast Cache implements ActionsSupport::Cache::Store API and can be
instantiated by passing the same parameters you would pass to Rails'
`config.cache_store` configuration option.

```ruby
class Application < Rails::Application
...
  config.cache_store = RailsFastCache::Store.new(:memory_store, { size: 64.megabytes })
```
