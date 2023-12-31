# coding: utf-8
require 'helper'
require 'epub/cfi'

class TestCFI < Test::Unit::TestCase
  def test_escape
    assert_equal '^^^[^]^(^)^,^;^=', EPUB::CFI.escape('^[](),;=')
  end

  def test_unescape
    assert_equal '^[](),;=', EPUB::CFI.unescape('^^^[^]^(^)^,^;^=')
  end

  class TestLocation < self
    def test_copy
      cfi = EPUB::CFI::Parser.parse('epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])')
      cloned = cfi.clone
      assert_equal cfi, cloned
      assert_not_same cfi, cloned
    end

    def test_join
      location = EPUB::CFI::Parser.parse('epubcfi(/6/14[chap05ref])')
      # @type var location: EPUB::CFI::Location
      other_path = EPUB::CFI::Path.new([EPUB::CFI::Path.new([
        EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('body01')),
        EPUB::CFI::Step.new(10),
        EPUB::CFI::Step.new(2),
        EPUB::CFI::Step.new(1)
      ])])
      joined = location.join(other_path)

      assert_equal 'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1)', joined.to_s
    end
  end

  class TestPath < self
    data([
      'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])',
      'epubcfi(/6/4!/4/10/2/1:3[Ф-"spa ce"-99%-aa^[bb^]^^])',
      'epubcfi(/6/4!/4/10/2/1:3[Ф-"spa%20ce"-99%25-aa^[bb^]^^])',
      'epubcfi(/6/4!/4/10/2/1:3[%d0%a4-"spa%20ce"-99%25-aa^[bb^]^^])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[,y])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[;s=b])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy;s=b])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2[;s=b])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/16[svgimg])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:0)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:0)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[iframe01]!/4/6,:6,/8:1)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[iframe01],!/4/6:6,/8:1)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[iframe01],/4!/4/6:6,/8:1)',
    ].reduce({}) {|data, cfi|
      data[cfi] = cfi
      data
    })
    def test_to_s(cfi)
      assert_equal cfi, EPUB::CFI::Parser.parse(cfi).to_s
    end

    def test_compare
      assert_equal -1, epubcfi('/6/4[id]') <=> epubcfi('/6/5')
      assert_equal 0, epubcfi('/6/4') <=> epubcfi('/6/4')
      assert_equal 1, epubcfi('/6/4') <=> epubcfi('/4/6')
      assert_equal 1, epubcfi('/6/4!/4@3:7') <=> epubcfi('/6/4!/4')
      assert_equal 1,
        epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]') <=>
        epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]')
      assert_nil epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3:10') <=>
        epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3!:10')
      assert_equal 1, epubcfi('/6/4') <=> epubcfi('/6')
    end
  end

  class TestRange < self
    def test_attributes
      parent = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]')
      first = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/1:1')
      last = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3:4')
      range = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4')
      # @type var range: EPUB::CFI::Range
      assert_equal 0, first <=> range.first
      assert_equal 0, last <=> range.last

      assert_equal 0, parent <=> range.parent_path
    end

    def test_to_s
      cfi = '/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4'
      assert_equal 'epubcfi(' + cfi + ')', epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4').to_s
    end

    def test_cover
      range = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4')
      # @type var range: EPUB::CFI::Range
      assert_true range.cover? epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/2/4')
    end
  end

  class TestStep < self
    def test_to_s
      assert_equal '/6', EPUB::CFI::Step.new(6).to_s
      assert_equal '/4[id]', EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('id')).to_s
    end

    def test_compare
      assert_equal 0, EPUB::CFI::Step.new(6) <=> EPUB::CFI::Step.new(6, 'assertion')
      assert_equal -1, EPUB::CFI::Step.new(6) <=> EPUB::CFI::Step.new(7)
    end
  end

  class TestIDAssertion < self
    def test_to_s
      assert_equal '[id]', EPUB::CFI::IDAssertion.new('id').to_s
      assert_equal '[id;p=a]', EPUB::CFI::IDAssertion.new('id', {'p' => ['a']}).to_s
    end
  end

  class TestTextLocationAssertion < self
    def test_to_s
      assert_equal '[yyy]', EPUB::CFI::TextLocationAssertion.new('yyy').to_s
      assert_equal '[xx,y]', EPUB::CFI::TextLocationAssertion.new('xx', 'y').to_s
      assert_equal '[,y]', EPUB::CFI::TextLocationAssertion.new(nil, 'y').to_s
      assert_equal '[;s=b]', EPUB::CFI::TextLocationAssertion.new(nil, nil, {'s' => ['b']}).to_s
      assert_equal '[yyy;s=b]', EPUB::CFI::TextLocationAssertion.new('yyy', nil, {'s' => ['b']}).to_s
    end
  end

  class TestCharacterOffset < self
    def test_to_s
      assert_equal ':1', EPUB::CFI::CharacterOffset.new(1).to_s
      assert_equal ':2[yyy]', EPUB::CFI::CharacterOffset.new(2, EPUB::CFI::TextLocationAssertion.new('yyy')).to_s
    end

    def test_compare
      assert_equal 0,
        EPUB::CFI::CharacterOffset.new(3) <=>
        EPUB::CFI::CharacterOffset.new(3, EPUB::CFI::TextLocationAssertion.new('yyy'))
      assert_equal -1,
        EPUB::CFI::CharacterOffset.new(4) <=>
        EPUB::CFI::CharacterOffset.new(5)
      assert_equal 1,
        EPUB::CFI::CharacterOffset.new(4, EPUB::CFI::TextLocationAssertion.new(nil, 'xx')) <=>
        EPUB::CFI::CharacterOffset.new(2)
    end
  end

  class TestSpatialOffset < self
    def test_to_s
      assert_equal '@0.5:30.2', EPUB::CFI::TemporalSpatialOffset.new(nil, 0.5, 30.2).to_s
      assert_equal '@0:100', EPUB::CFI::TemporalSpatialOffset.new(nil, 0, 100).to_s
      assert_equal '@50:50.0', EPUB::CFI::TemporalSpatialOffset.new(nil, 50, 50.0).to_s
    end

    def test_compare
      assert_equal 0,
        EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40)
      assert_equal 1,
        EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(nil, 40, 30)
    end
  end

  class TestTemporalOffset < self
    def test_to_s
      assert_equal '~23.5', EPUB::CFI::TemporalSpatialOffset.new(23.5).to_s
    end

    def test_compare
      assert_equal 0,
        EPUB::CFI::TemporalSpatialOffset.new(23.5) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5)
      assert_equal -1,
        EPUB::CFI::TemporalSpatialOffset.new(23) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5)
    end
  end

  class TestTemporalSpatialOffset < self
    def test_to_s
      assert_equal '~23.5@50:30.0', EPUB::CFI::TemporalSpatialOffset.new(23.5, 50, 30.0).to_s
    end

    def test_compare
      assert_equal 0,
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40.0)
      assert_equal 1,
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5)
      assert_equal -1,
        EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40)
      assert_equal -1,
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 50)
      assert_equal 1,
        EPUB::CFI::TemporalSpatialOffset.new(24, 30, 40) <=>
        EPUB::CFI::TemporalSpatialOffset.new(23.5, 100, 100)
    end
  end

  private

  def epubcfi(string)
    EPUB::CFI::Parser.new.parse(string)
  end

  def assert_equal_node(expected, actual, message='')
    diff = AssertionMessage.delayed_diff(expected.to_s, actual.to_s)
    message = build_message(message, <<EOT, expected, actual, diff)
<?>
expected but was
<?>.?
EOT
    assert_block message do
      expected.tdiff_equal actual
    end
  end
end
