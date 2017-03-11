require 'helper'
require 'epub/cfi'

class TestCFI < Test::Unit::TestCase

  def test_version
    version = EPUB::CFI.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

end
