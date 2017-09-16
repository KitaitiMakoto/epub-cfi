# encoding: utf-8
require 'rake'

task :default => "lib/epub/cfi/parser.tab.rb"

file "lib/epub/cfi/parser.tab.rb" do |target|
  sh "racc #{target.name.sub("tab.rb", "y")}"
end

require "rake/clean"
CLOBBER.include "lib/epub/cfi/parser.tab.rb"

require 'rubygems/tasks'
Gem::Tasks.new
task :build => [:clean, "lib/epub/cfi/parser.tab.rb"]

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
task :test => "lib/epub/cfi/parser.tab.rb"

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard
