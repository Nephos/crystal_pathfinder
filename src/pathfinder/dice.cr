require "./die"
require "./fixed_value"

module Pathfinder
  class Dice
    class ParsingError < Exception
    end

    @count : Int32
    @die : Pathfinder::Die

    def initialize(@count, @die)
    end

    def initialize(@count, die_type : Int32)
      @die = Pathfinder::Die.new(1..die_type)
    end

    def reverse : Dice
      Dice.new @count, @die.reverse
    end

    # Returns the `Dice` parsed from `str`.
    private def self.parse_string(str : String, strict = true) : NamedTuple(str: String, dice: Pathfinder::Dice)
      match = str.match(/\A(\d+)(?:(?:d)(\d+))?#{strict ? "\\Z" : ""}/i)
      raise ParsingError.new("Parsing Error: dice, near to '#{str}'") if match.nil?
      count = match[1]
      die = match[2]?
      if die.nil?
        return {str: match[0], dice: Pathfinder::Dice.new(1, Pathfinder::FixedValue.new(count.to_i))}
      else
        return {str: match[0], dice: Pathfinder::Dice.new(count.to_i, die.to_i)}
      end
    end

    # Yield the `Dice` parsed from `str`.
    def self.parse(str : String, strict = true) : String
      data = parse_string(str, strict)
      yield data[:dice]
      return data[:str]
    end

    def self.parse(str : String, strict = true) : Pathfinder::Dice
      data = parse_string(str, strict)
      return data[:dice]
    end

    # Returns the unconsumed string
    #
    # Parse `str`, and yield a `Dice` parsed
    # ```
    # rest = Dice.consume("1d6+2") do |dice|
    #   # dice = Dice.new(1, Die.new(1..6))
    # end
    #   # rest = "+2"
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

    def average : Float64
      @die.average * @count
    end

    def average_details : Array(Float64)
      @count.times.to_a.map { @die.average }
    end

    def test : Int32
      @count.times.reduce(0) { |r, l| r + @die.test }
    end

    def test_details : Array(Int32)
      @count.times.to_a.map { @die.test }
    end
  end
end
