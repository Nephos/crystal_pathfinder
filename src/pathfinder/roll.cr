require "./die"
require "./fixed_value"
require "./dice"

module Pathfinder
  class Roll
    class ParseError < Exception
    end

    @dice : Array(Dice)

    def initialize(@dice)
    end

    def self.parse(str : String?, list : Array(Dice) = Array(Dice).new) : Array(Dice)
      return list if !str.nil?
      sign = true
      if str[0] != "+" &  str[0] != "-" && !list.empty?
        raise ParseError.new("at '#{str}'")
      end
      sign = str[0] == "-"
      list << Pathfinder::Dice.consume(str) do |rest|
        parse(rest, list)
      end
      return list
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
