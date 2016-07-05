require "./rollable"

module Pathfinder
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
  class Die < Rollable
    @faces : Range(Int32, Int32)

    def initialize(@faces)
    end

    def initialize(nb_faces : Int32)
      @faces = 1..nb_faces
    end

    def reverse : Die
      Die.new -max..-min
    end

    def max : Int32
      @faces.end
    end

    def min : Int32
      @faces.begin
    end

    def test : Int32
      @faces.to_a.sample
    end

    def average : Float64
      @faces.reduce { |r, l| r + l }.to_f64 / @faces.size
    end
  end
end
