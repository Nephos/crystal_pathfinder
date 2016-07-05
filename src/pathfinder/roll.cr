require "./die"
require "./fixed_value"
require "./dice"

module Pathfinder
  # `Roll` is a list of `Dice`.
  #
  # It is rollable, making the sum of each `Dice` values.
  # It is also possible to get the details of a roll, using the methods
  # `min_details`, `max_details`, `average_details`, `test_details`
  #
  # Example:
  # ```
  # r = Rollable.parse "1d6+2" # note: it also support "1d6 + 2"
  # r.min                      # => 3
  # r.max                      # => 9
  # r.average                  # => 5.5
  # r.test                     # => the sum a a random value in 1..6 and 2
  # ```
  class Roll
    class ParsingError < Exception
    end

    @dice : Array(Dice)

    def initialize(@dice)
    end

    def reverse! : Roll
      @dice.each { |die| die.reverse! }
      self
    end

    # Reverse the values of the `Roll`.
    #
    # Example:
    # ```
    # Roll.parse("1d6").reverse # => -1d6
    # ```
    def reverse : Roll
      Roll.new @dice.map { |die| die.reverse }
    end

    # Parse the string and return an array of `Dice`
    private def self.parse_str(str : String?, list : Array(Dice) = Array(Dice).new) : Array(Dice)
      return list if str.nil?
      str = str.strip
      sign = str[0]
      if sign != '+' && sign != '-' && !list.empty?
        raise ParsingError.new("Parsing Error: roll, near to '#{str}'")
      end
      str = str[1..-1] if sign == '-' || sign == '+'
      rest = Dice.consume(str) do |dice|
        list << (sign == '-' ? dice.reverse : dice)
      end
      parse_str(rest, list)
      return list
    end

    # Parse the string and returns a new `Roll` object
    def self.parse(str : String) : Roll
      return Roll.new(parse_str(str))
    end

    {% for ft in ["min", "max", "test"] %}
    def {{ ft.id }} : Int32
      @dice.reduce(0) { |r, l| r + l.{{ ft.id }} }
    end

    def {{ (ft + "_details").id }} : Array(Int32)
      @dice.map {|dice| dice.{{ (ft + "_details").id }} }.flatten
    end
    {% end %}

    def average : Float64
      @dice.reduce(0.0) { |r, l| r + l.average }
    end

    def average_details : Array(Float64)
      @dice.map { |dice| dice.average_details }.flatten
    end
  end
end
