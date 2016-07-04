require "./die"
require "./fixed_value"
require "./dice"

module Pathfinder
  class Roll

    @dice : Array(Die)

    def initialize(@dice)
    end

    def self.parse(str : String, list : Array(Die) = Array(Die).new) : Array(Die)
      rest = Pathfinder::Dice.consume(str) { |dice| list << dice }
      return list
    end

    def min : Int32
      @dice.map{|d| d.min }.sum
    end

    def max : Int32
      @dice.map{|d| d.max }.sum
    end

    def average : Int32
      @dice.map{|d| d.average }.sum
    end

    def test : Int32
      @dice.map{|d| d.test }.sum
    end

  end
end
