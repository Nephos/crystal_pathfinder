require "./die"

module Pathfinder
  module FixedValue
    def self.new(value : Int32)
      Pathfinder::Die.new(value..value)
    end
  end
end
