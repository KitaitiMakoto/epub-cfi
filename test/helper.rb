require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require 'test/unit'

class Test::Unit::TestCase
end
