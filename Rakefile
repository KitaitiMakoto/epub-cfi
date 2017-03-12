# encoding: utf-8
require 'rake'

task :default => :test

file "lib/epub/cfi/parser.tab.rb" do |target|
  sh "racc #{target.name.sub("tab.rb", "y")}"
end


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
