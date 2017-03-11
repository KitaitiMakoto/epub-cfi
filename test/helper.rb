require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require 'test/unit'
require "test/unit/notify"

require "pretty_backtrace"
PrettyBacktrace.enable

class Test::Unit::TestCase
end
