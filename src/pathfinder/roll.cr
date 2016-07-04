require "./die"
require "./fixed_value"

module Pathfinder
  class Roll

    @dice : Array(Die)

    def initialize(@dice)
    end

    def self.parse(str : String)
    end

    def min : Int32
      @dice.map{|d| d.min }.sum
    end

    def max : Int32
      @dice.map{|d| d.max }.sum
    end

    def test : Int32
      @dice.map{|d| d.test }.sum
    end

  end
end
