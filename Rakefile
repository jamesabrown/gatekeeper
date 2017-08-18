require 'rake'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new(:test) do |t|
  t.pattern = Dir.glob('spec/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = Dir.glob('spec/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

task default: :test
