# frozen_string_literal: true

require './lib/rails-fast-cache/version'

Gem::Specification.new do |s|
  s.name = 'rails-fast-cache'
  s.version = RailsFastCache::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.1.0'
  s.license = 'MIT'

  s.authors = ['Filippo Liverani']
  s.email = ['1382917+filippoliverani@users.noreply.github.com']
  s.description = 'Drop-in improvement for Rails cache'
  s.summary = 'Drop-in improvement for Rails cache, providing enhanced performance with asynchronous processing and better default serialization and compression'
  s.homepage = 'https://github.com/filippoliverani/rails-fast-cache'
  s.files = `git ls-files lib LICENSE.txt README.md`.split($RS)
  s.test_files = `git ls-files spec`.split($RS)
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activejob', '>= 7.1'
  s.add_runtime_dependency 'activesupport', '>= 7.1'
  s.add_runtime_dependency 'brotli', '>= 0.4'
  s.add_runtime_dependency 'msgpack', '>= 1.7'

  s.add_development_dependency 'benchmark-ips', '>= 2.0'
  s.add_development_dependency 'redis', '>= 5.0'
  s.add_development_dependency 'rspec', '>= 3.0'
end
