# encoding: utf-8
require 'rake'

task :default => "lib/epub/cfi/parser.tab.rb"

desc "Build EPUB CFI parser"
file "lib/epub/cfi/parser.tab.rb" => "lib/epub/cfi/parser.y" do |task|
  sh "racc #{task.source}"
end

require "rake/clean"
CLOBBER.include "lib/epub/cfi/parser.tab.rb"

require 'rubygems/tasks'
Gem::Tasks.new
task :build => "lib/epub/cfi/parser.tab.rb"

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
task :test => "lib/epub/cfi/parser.tab.rb"

require 'yard'
YARD::Rake::YardocTask.new

require "steep"
desc "Check type"
task typecheck: "lib/epub/cfi/parser.tab.rb" do
  Steep::Drivers::Check.new(stdout: $stdout, stderr: $stderr).run
end
