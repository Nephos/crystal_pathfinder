require "./is_rollable"

module Rollable
  # A `Die` is a range of Integer values.
  # It is rollable.
  #
  # Example:
  # ```
  # d = Die.new(1..6)
  # d.min     # => 1
  # d.max     # => 6
  # d.average # => 3.5
  # d.test    # => a random value included in 1..6
  # ```
  class Die < IsRollable
    @faces : Range(Int32, Int32)

    def initialize(@faces)
    end

    def initialize(nb_faces : Int32)
      @faces = 1..nb_faces
    end

    # Reverse the values
    #
    # Example:
    # ```
    # Die.new(1..6).reverse # => Die.new -6..-1
    # ```
    def reverse : Die
      Die.new -max..-min
    end

    def max : Int32
      @faces.end
    end

    def min : Int32
      @faces.begin
    end

    # Returns a random value in the range of the dice
    def test : Int32
      @faces.to_a.sample
    end

    def average : Float64
      @faces.reduce { |r, l| r + l }.to_f64 / @faces.size
    end
  end
end
