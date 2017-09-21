require "epub/cfi/parser.tab"

class EPUB::CFI::Parser
  include Comparable

  UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN = /\u0009|\u000A|\u000D|[\u0022-\u0027]|[\u002A-\u002B]|\u002D|[\u0030-\u0039]|\u003C|[\u003E-\u0040]|[\u0041-\u005A]|\u005C|[\u005F-\u007D]|[\u007F-\uD7FF]|[\uE000-\uFFFD]|[\u10000-\u10FFFF]/ # excluding special chars and space(\u0020) and dot(\u002E) and colon(\u003A) and tilde(\u007E) and atmark(\u0040) and solidus(\u002F) and exclamation mark(\u0021)
  UNICODE_CHARACTER_PATTERN = Regexp.union(UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN, Regexp.new(Regexp.escape(EPUB::CFI::SPECIAL_CHARS), / \.:~@!/))

  class << self
    def parse(string, debug: $DEBUG)
      new(debug: debug).parse(string)
    end
  end

  def initialize(debug: $DEBUG)
    @yydebug = debug
    super()
  end

  def parse(string)
    if string.start_with? 'epubcfi('
      string = string['epubcfi('.length .. -2]
    end
    @scanner = StringScanner.new(string, true)
    do_parse
  end

  def next_token
    return [false, false] if @scanner.eos?

    case
    when @scanner.scan(/[1-9]/)
      [:DIGIT_NON_ZERO, @scanner[0]]
    when @scanner.scan(/0/)
      [:ZERO, @scanner[0]]
    when @scanner.scan(/ /)
      [:SPACE, @scanner[0]]
    when @scanner.scan(/\^/)
      [:CIRCUMFLEX, @scanner[0]]
    when @scanner.scan(/\[/)
      [:OPENING_SQUARE_BRACKET, @scanner[0]]
    when @scanner.scan(/\]/)
      [:CLOSING_SQUARE_BRACKET, @scanner[0]]
    when @scanner.scan(/\(/)
      [:OPENING_PARENTHESIS, @scanner[0]]
    when @scanner.scan(/\)/)
      [:CLOSING_PARENTHESIS, @scanner[0]]
    when @scanner.scan(/,/)
      [:COMMA, @scanner[0]]
    when @scanner.scan(/;/)
      [:SEMICOLON, @scanner[0]]
    when @scanner.scan(/=/)
      [:EQUAL, @scanner[0]]
    when @scanner.scan(/\./)
      [:DOT, @scanner[0]]
    when @scanner.scan(/:/)
      [:COLON, @scanner[0]]
    when @scanner.scan(/~/)
      [:TILDE, @scanner[0]]
    when @scanner.scan(/@/)
      [:ATMARK, @scanner[0]]
    when @scanner.scan(/\//)
      [:SOLIDUS, @scanner[0]]
    when @scanner.scan(/!/)
      [:EXCLAMATION_MARK, @scanner[0]]
    when @scanner.scan(UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN)
      [:UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK, @scanner[0]]
    else
      raise 'unexpected character'
    end
  end
end

module EPUB::CFI
  module_function

  # Parses the given string, creates a new {CFI} object and return it.
  #
  # @example Parses a URI fragment string
  #   EPUB::CFI.parse("epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])")
  #   #=> #<EPUB::CFI::Location:/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]>
  #
  # @example Parses a path string
  #   EPUB::CFI.parse("/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]")
  #   #=> #<EPUB::CFI::Location:/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]>
  #
  # @param string [String]
  # @return [CFI]
  # @raise [Racc::ParseError] if given string is invalid
  def parse(string)
    EPUB::CFI::Parser.parse(string)
  end
end

# Creates a new {CFI} object from the given string and return it.
#
# @example Creates from a URI fragment string
#   EPUB::CFI("epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])")
#   #=> #<EPUB::CFI::Location:/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]>
#
# @example Creates from a path string
#   EPUB::CFI("/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]")
#   #=> #<EPUB::CFI::Location:/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]>
#
# @param string [String]
# @return [CFI]
# @raise [Racc::ParseError] if given string is invalid
# @see CFI.parse
def EPUB::CFI(string)
  EPUB::CFI.parse(string)
end
