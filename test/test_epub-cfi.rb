require 'helper'
require 'epub/cfi'

class TestEpub::Cfi < Test::Unit::TestCase

  def test_version
    version = Epub::Cfi.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

end
