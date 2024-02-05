require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :benchmark do
  task :data do
    data = 1000.times.map do |i|
      OpenStruct.new(
        array: Array.new(10) { SecureRandom.hex(1024) },
        hash: Hash.new { SecureRandom.hex(1024) }
    )
    File.write('benchmark/data.bin', data)
  end
end
