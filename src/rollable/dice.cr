# coding: utf-8
require "./is_rollable"
require "./die"
require "./fixed_value"

module Rollable
  # A `Dice` is a amount of `Die`.
  # It is rollable exactly like a classic `Die`
  #
  # It is also possible to get the details of a roll, using the methods
  # `.min_details`, `.max_details`, `.average_details`, `.test_details`
  #
  # Example:
  # ```
  # d = Dice.parse "2d6"
  # d.min         # => 2
  # d.max         # => 12
  # d.average     # => 7
  # d.min_details # => [1, 1]
  # d.test        # => the sum of 2 random values between 1..6
  # ```
  class Dice < IsRollable
    @count : Int32
    @die : Die

    getter count, die

    def initialize(@count, @die)
      check_count
    end

    # Create a `Dice` with "die_type" faces.
    def initialize(@count, die_type : Int32)
      @die = Die.new(1..die_type)
    end

    private def check_count
      if @count < 0
        @count = -@count
        @die.reverse!
      end
      self
    end

    def count=(count : Int32)
      @count = count
      check_count
    end

    def clone
      Dice.new(@count, @die.clone)
    end

    def fixed?
      @die.fixed?
    end

    # Reverse the `Die` of the `Dice`.
    #
    # Example:
    # ```
    # Dice.parse("1d6").reverse # => -1d6
    # ```
    def reverse : Dice
      Dice.new -@count, @die
    end

    def reverse!
      @die.reverse!
      self
    end

    {% for ft in ["min", "max"] %}
    def {{ ft.id }} : Int32
      @die.{{ ft.id }} * @count
    end

    def {{ (ft + "_details").id }} : Array(Int32)
      @count.times.to_a.map{ @die.{{ ft.id }} }
    end
    {% end %}

    # Roll an amount of `Dice` as specified, and return the sum
    def test : Int32
      @count.times.reduce(0) { |r, l| r + @die.test }
    end

    # Roll an amount of `Dice` as specified, and return the values
    def test_details : Array(Int32)
      @count.times.to_a.map { @die.test }
    end

    def average : Float64
      @die.average * @count
    end

    def average_details : Array(Float64)
      @count.times.to_a.map { @die.average }
    end

    def ==(right : Dice)
      @count == right.count && @die == right.die
    end

    {% for op in [">", "<", ">=", "<="] %}
    def {{ op.id }}(right : Dice)
      average != right.average ?
      average {{ op.id }} right.average :
      max != right.max ?
      max {{ op.id }} right.max :
      min {{ op.id }} right.min
    end
    {% end %}

    def <=>(right : Dice)
      average != right.average ? average - right.average <=> 0 : max != right.max ? max - right.max <=> 0 : min - right.min <=> 0
    end
  end
end

require "./dice/*"
