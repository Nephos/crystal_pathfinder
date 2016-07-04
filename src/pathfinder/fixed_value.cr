require "./die"

module Pathfinder
  class FixedValue < Die

    def initialize(value : Int32)
      super(value..value)
    end

  end
end
