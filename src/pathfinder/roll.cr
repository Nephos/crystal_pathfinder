require "./die"
require "./fixed_value"
require "./dice"

module Pathfinder
  class Roll
    class ParsingError < Exception
    end

    @dice : Array(Dice)

    def initialize(@dice)
    end

    def reverse! : Roll
      @dice.each{|die| die.reverse! }
      self
    end

    def reverse : Roll
      Roll.new @dice.map{|die| die.reverse }
    end

    private def self.parse_str(str : String?, list : Array(Dice) = Array(Dice).new) : Array(Dice)
      return list if str.nil?
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

    def self.parse(str : String) : Roll
      return Roll.new(parse_str(str))
    end

    {% for ft in ["min", "max", "test"] %}
    def {{ ft.id }} : Int32
      @dice.reduce(0) { |r, l| r + l.{{ ft.id }} }
    end
    {% end %}

    def average : Float64
      @dice.reduce(0.0) { |r, l| r + l.average }
    end
  end
end
