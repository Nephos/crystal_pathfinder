require "./die"
require "./fixed_value"

module Pathfinder
  class Dice
    class ParseError < Exception
    end

    @count : Int32
    @die : Pathfinder::Die

    def initialize(@count, @die)
    end

    def initialize(@count, die_type : Int32)
      @die = Pathfinder::Die.new(1..die_type)
    end

    # Returns a `Dice` parsed from `str`.
    # Yield the string parsed
    def self.parse(str : String, strict = true)  : Pathfinder::Dice
      match = str.match(/\A(\d+)(?:(?:d)(\d+))?#{strict ? "\Z" : ""}/i)
      raise ParseError.new("#{str}") if match.nil?
      count = match[1]
      die = match[2]?
      yield match[0]
      return Pathfinder::Dice.new(1, Pathfinder::FixedValue.new(count.to_i)) if die.nil?
      return Pathfinder::Dice.new(count.to_i, die.to_i)
    end

    # Parse the dice and return it but does not yield
    def self.parse(str : String, struct = true) : Pathfinder::Dice
      return parse(str, strict) {}
    end

    # Returns a `Dice` parsed
    #
    # Parse `str`, and yield the unconsumed string
    # ```
    # dice = Dice.consume("1d6+2") do |rest|
    #   # rest = "+2"
    # end
    # # dice = Dice.new(1, Die.new(1..6))
    # ```
    def self.consume(str : String)
      str = str.strip
      dice = parse(str, false) do |consumed|
        yield consumed.size >= str.size ? nil : str[consumed.size..-1]
      end
      return dice
    end

    {% for ft in ["min", "max"] %}
    def {{ ft.id }} : Int32
      @die.{{ ft.id }} * @count
    end
    {% end %}

    def average : Float64
      @die.average * @count
    end

    def test : Int32
      @count.times.reduce(0) { |r, l| r + @die.test }
    end
  end
end
