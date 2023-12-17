require 'epub/cfi/version'

module EPUB
  module CFI
    SPECIAL_CHARS = '^[](),;=' # "5E", "5B", "5D", "28", "29", "2C", "3B", "3D"
    RE_ESCAPED_SPECIAL_CHARS = Regexp.escape(SPECIAL_CHARS)

    class << self
      # Escapes special characters in string
      #
      # @example
      #   EPUB::CFI.escape("2[1]") #=> "2^[1^]"
      #
      # @param string [String] Component string of EPUB CFI
      # @return [String] Escaped comonent string
      def escape(string)
        string.gsub(/([#{RE_ESCAPED_SPECIAL_CHARS}])/o, '^\1')
      end

      # Unescape escaped characters in string
      #
      # @example
      #   EPUB::CFI.unescape("2^[1^]") #=> "2[1]"
      #
      # @param string [String] Escape component string of EPUB CFI
      # @return [String] Unescaped component string
      def unescape(string)
        string.gsub(/\^([#{RE_ESCAPED_SPECIAL_CHARS}])/o, '\1')
      end
    end

    # {Location} indicates a point in an EPUB Publication.
    class Location
      include Comparable

      attr_reader :paths

      class << self
        def from_parent_and_subpath(parent_path, subpath)
          new(resolve_path(parent_path, subpath))
        end

        private

        def resolve_path(parent_path, subpath)
          paths = parent_path.collect(&:dup)
          return paths unless subpath

          subpath = subpath.collect(&:dup)
          offset = subpath.last.offset
          paths.last.steps.concat subpath.shift.steps
          paths.concat subpath
          paths.last.instance_variable_set :@offset, offset

          paths
        end
      end

      def initialize(paths=[])
        @paths = paths
      end

      def initialize_copy(original)
        @paths = original.paths.collect(&:dup)
      end

      def <=>(other)
        index = 0
        other_paths = other.paths
        cmp = nil
        paths.each do |path|
          other_path = other_paths[index]
          return 1 unless other_path
          cmp = path <=> other_path
          break unless cmp == 0
          index += 1
        end

        unless cmp == 0
          if cmp == 1 and paths[index].offset and other_paths[index + 1]
            return nil
          else
            return cmp
          end
        end

        return nil if paths.last.offset && other_paths[index]

        return -1 if other_paths[index]

        0
      end

      def path_string
        paths.join('!')
      end

      def to_s
       "epubcfi(#{path_string})"
      end

      def inspect
        "#<#{self.class}:#{path_string}>"
      end

      def join(*other_paths)
        new_paths = paths.dup
        other_paths.each do |path|
          new_paths << path
        end
        self.class.new(new_paths)
      end
    end

    class Path
      attr_reader :steps, :offset

      def initialize(steps=[], offset=nil)
        @steps, @offset = steps, offset
      end

      def initialize_copy(original)
        @steps = original.steps.collect(&:dup)
        @offset = original.offset.dup if original.offset
      end

      def to_s
        @string_cache ||= (steps.join + offset.to_s)
      end

      def <=>(other)
        other_steps = other.steps
        index = 0
        steps.each do |step|
          other_step = other_steps[index]
          return 1 unless other_step
          cmp = step <=> other_step
          return cmp unless cmp == 0
          index += 1
        end

        return -1 if other_steps[index]

        other_offset = other.offset
        if offset
          if other_offset
            offset <=> other_offset
          else
            1
          end
        else
          if other_offset
            -1
          else
            0
          end
        end
      end
    end

    class Range < ::Range
      attr_accessor :parent_path, :start_subpath, :end_subpath

      class << self
        def from_parent_and_start_and_end(parent_path, start_subpath, end_subpath)
          first = Location.from_parent_and_subpath(parent_path, start_subpath)
          last = Location.from_parent_and_subpath(parent_path, end_subpath)

          new_range = new(first, last)

          new_range.parent_path = Location.new(parent_path)
          new_range.start_subpath = start_subpath.join("!")
          new_range.end_subpath = end_subpath.join("!")

          new_range
        end
      end

      def to_s
        @string_cache ||= "epubcfi(#{@parent_path.path_string},#{@start_subpath},#{@end_subpath})"
      end
    end

    class Step
      attr_reader :value, :assertion
      alias step value

      def initialize(value, assertion=nil)
        @value, @assertion = value, assertion
        @string_cache = nil
      end

      def initialize_copy(original)
        @value = original.value
        @assertion = original.assertion.dup if original.assertion
      end

      def to_s
        @string_cache ||= "/#{value}#{assertion}" # need escape?
      end

      def <=>(other)
        value <=> other.value
      end

      def element?
        value.even?
      end

      def character_data?
        value.odd?
      end
    end

    class IDAssertion
      attr_reader :id, :parameters

      def initialize(id, parameters={})
        @id, @parameters = id, parameters
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = '['
        string_cache << CFI.escape(id) if id
        parameters.each_pair do |key, values|
          value = values.join(',')
          string_cache << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        string_cache << ']'
        @string_cache = string_cache
      end
    end

    class TextLocationAssertion
      attr_reader :preceded, :followed, :parameters

      def initialize(preceded=nil, followed=nil, parameters={})
        @preceded, @followed, @parameters = preceded, followed, parameters
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = '['
        string_cache << CFI.escape(preceded) if preceded
        string_cache << ',' << CFI.escape(followed) if followed
        parameters.each_pair do |key, values|
          value = values.join(',')
          string_cache << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        string_cache << ']'
        @string_cache = string_cache
      end
    end

    class CharacterOffset
      attr_reader :value, :assertion
      alias offset value

      def initialize(value, assertion=nil)
        @value, @assertion = value, assertion
        @string_cache = nil
      end

      def to_s
        @string_cache ||= ":#{value}#{assertion}" # need escape?
      end

      def <=>(other)
        value <=> other.value
      end
    end

    class TemporalSpatialOffset
      attr_reader :temporal, :x, :y, :assertion

      def initialize(temporal=nil, x=nil, y=nil, assertion=nil)
        raise RangeError, "dimension must be in 0..100 but passed #{x}" unless (0.0..100.0).cover?(x) if x
        raise RangeError, "dimension must be in 0..100 but passed #{y}" unless (0.0..100.0).cover?(y) if y
        warn "Assertion is passed to #{self.class} but cannot know how to handle with it: #{assertion}" if assertion
        @temporal, @x, @y, @assertion = temporal, x, y, assertion
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = ''
        string_cache << "~#{temporal}" if temporal
        string_cache << "@#{x}:#{y}" if x or y
        @string_cache = string_cache
      end

      # @note should split the class to spatial offset and temporal-spatial offset?
      def <=>(other)
        return -1 if temporal.nil? and other.temporal
        return 1 if temporal and other.temporal.nil?
        cmp = temporal <=> other.temporal
        return cmp unless cmp == 0
        return -1 if y.nil? and other.y
        return 1 if y and other.y.nil?
        cmp = y <=> other.y
        return cmp unless cmp == 0
        return -1 if x.nil? and other.x
        return 1 if x and other.x.nil?
        cmp = x <=> other.x
      end
    end
  end
end

require "epub/cfi/parser"
