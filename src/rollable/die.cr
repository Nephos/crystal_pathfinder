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
  # TODO: make it a Struct ?
  class Die < IsRollable
    @faces : Range(Int32, Int32)

    getter faces

    def initialize(@faces)
    end

    def clone
      Die.new(@faces)
    end

    def initialize(nb_faces : Int32)
      @faces = 1..nb_faces
    end

    # Number of faces of the `Die`
    def size
      @faces.size
    end

    def fixed?
      size == 1
    end

    def negative?
      min < 0 && max < 0
    end

    def like?(other : Die)
      @faces == other.faces || @faces == other.reverse.faces
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

    def reverse!
      @faces = -max..-min
      self
    end

    def max : Int32
      @faces.end
    end

    def min : Int32
      @faces.begin
    end

    # Return a random value in the range of the dice
    def test : Int32
      @faces.to_a.sample
    end

    # Mathematical expectation.
    #
    # A d6 will have a expected value of 3.5
    def average : Float64
      @faces.reduce { |r, l| r + l }.to_f64 / @faces.size
    end

    # Return a string.
    # - It may be a fixed value ```(n..n) => "#{n}"```
    # - It may be a dice ```(1..n) => "D#{n}"```
    # - Else, ```(a..b) => "D(#{a},#{b})"```
    def to_s : String
      if self.size == 1
        min.to_s
      elsif self.min == 1
        "D#{self.max}"
      else
        "D(#{self.min},#{self.max})"
      end
    end

    def ==(right : Die)
      @faces == right.faces
    end

    {% for op in [">", "<", ">=", "<="] %}
    def {{ op.id }}(right : Die)
      average != right.average ?
      average {{ op.id }} right.average :
      max != right.max ?
      max {{ op.id }} right.max :
      min {{ op.id }} right.min
    end
    {% end %}

    def <=>(right : Die)
      average != right.average ? average - right.average <=> 0 : max != right.max ? max - right.max <=> 0 : min - right.min <=> 0
    end
  end
end
