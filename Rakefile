# encoding: utf-8
require 'rake'

task :default => :test

require 'rubygems/tasks'
Gem::Tasks.new

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard
