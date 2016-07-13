# coding: utf-8
require "./is_rollable"
require "./die"
require "./fixed_value"

module Rollable
  # A `Dice` is a amount of `Die`.
  # It is rollable exactly like a classic `Die`
  #
  # It is also possible to get the details of a roll, using the methods
  # `.min_details`, `.max_details`, `.average_details`, `.test_details`
  #
  # Example:
  # ```
  # d = Dice.parse "2d6"
  # d.min         # => 2
  # d.max         # => 12
  # d.average     # => 7
  # d.min_details # => [1, 1]
  # d.test        # => the sum of 2 random values between 1..6
  # ```
  class Dice < IsRollable
    @count : Int32
    @die : Rollable::Die

    getter count, die

    def initialize(@count, @die)
    end

    # Create a `Dice` with "die_type" faces.
    def initialize(@count, die_type : Int32)
      @die = Rollable::Die.new(1..die_type)
    end

    # Reverse the `Die` of the `Dice`.
    #
    # Example:
    # ```
    # Dice.parse("1d6").reverse # => -1d6
    # ```
    def reverse : Dice
      Dice.new @count, @die.reverse
    end

    # Returns the `Dice` and the string parsed from `str`, in a `NamedTuple`
    # with "str" and "dice" keys.
    #
    # - If "strict" is true, then the string must end following the regex
    #   `\A\d+(d\d+)?\Z/i`
    #
    # - If "strict" is false, then the string doesn't have to finish following
    #   the regexp.
    private def self.parse_string(str : String, strict = true) : NamedTuple(str: String, dice: Rollable::Dice)
      match = str.match(/\A(\d+)(?:(?:d)(\d+))?#{strict ? "\\Z" : ""}/i)
      raise ParsingError.new("Parsing Error: dice, near to '#{str}'") if match.nil?
      count = match[1]
      die = match[2]?
      if die.nil?
        return {str: match[0], dice: Rollable::Dice.new(1, Rollable::FixedValue.new(count.to_i))}
      else
        return {str: match[0], dice: Rollable::Dice.new(count.to_i, die.to_i)}
      end
    end

    # Return a valid string parsed from `str`. (see `#parse_string`)
    #
    # Yields the `Dice` parsed from `str`.
    #
    # Then, it returns the string read.
    # If strict is false, only the valid string is returned.
    def self.parse(str : String, strict = true) : String
      data = parse_string(str, strict)
      yield data[:dice]
      return data[:str]
    end

    # Returns the `Dice` parsed. (see `#parse_string`)
    def self.parse(str : String, strict = true) : Rollable::Dice
      data = parse_string(str, strict)
      return data[:dice]
    end

    # Returns the unconsumed string.
    #
    # Parse `str`, and yield a `Dice` parsed.
    # It does not requires to be a full valid string
    # (see #parse when strict is false).
    # ```
    # rest = Dice.consume("1d6+2") do |dice|
    #   # dice = Dice.new(1, Die.new(1..6))
    # end
    # # rest = "+2"
    # ```
    def self.consume(str : String) : String?
      str = str.strip
      consumed = parse(str, false) do |dice|
        yield dice
      end
      return consumed.size >= str.size ? nil : str[consumed.size..-1]
    end

    {% for ft in ["min", "max"] %}
    def {{ ft.id }} : Int32
      @die.{{ ft.id }} * @count
    end

    def {{ (ft + "_details").id }} : Array(Int32)
      @count.times.to_a.map{ @die.{{ ft.id }} }
    end
    {% end %}

    # Roll an amount of `Dice` as specified, and return the sum
    def test : Int32
      @count.times.reduce(0) { |r, l| r + @die.test }
    end

    # Roll an amount of `Dice` as specified, and return the values
    def test_details : Array(Int32)
      @count.times.to_a.map { @die.test }
    end

    def average : Float64
      @die.average * @count
    end

    def average_details : Array(Float64)
      @count.times.to_a.map { @die.average }
    end

    # Return a string which represents the `Dice`
    #
    # - If the value is fixed ```(n..n)```, then it return the @count * value
    # - Else, it just add the count before the `Dice` like "{count}{dice.to_s}"
    def to_s : String
      if @die.size == 1
        (@count * @die.min).to_s
      else
        "#{@count}#{@die.to_s}"
      end
    end

    def ==(right : Dice)
      @count == right.count && @die == right.die
    end

    {% for op in [">", "<", ">=", "<="] %}
    def {{ op.id }}(right : Dice)
      average {{ op.id }} right.average
    end
    {% end %}

    def <=>(right : Dice)
      average > right.average || average < right.average
    end
  end
end
