require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require 'test/unit'
require "test/unit/notify"

class Test::Unit::TestCase
end
