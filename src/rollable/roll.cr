require "./is_rollable"
require "./die"
require "./fixed_value"
require "./dice"

module Rollable
  # `Roll` is a list of `Dice`.
  #
  # It is rollable, making the sum of each `Dice` values.
  # It is also possible to get the details of a roll, using the methods
  # `.min_details`, `.max_details`, `.average_details`, `.test_details`
  #
  # Example:
  # ```
  # r = Rollable.parse "1d6+2" # note: it also support "1d6 + 2"
  # r.min                      # => 3
  # r.max                      # => 9
  # r.average                  # => 5.5
  # r.test                     # => the sum of a random value in 1..6 and 2
  # ```
  class Roll < IsRollable
    @dice : Array(Dice)

    getter dice

    def initialize(@dice)
    end

    def clone
      Roll.new(@dice.clone)
    end

    # Reverse the values of the `Roll`.
    def reverse! : Roll
      @dice.each { |die| die.reverse! }
      self
    end

    # Return a reversed copy of the  `Roll`'s values.
    #
    # Example:
    # ```
    # Roll.parse("1d6").reverse # => -1d6
    # ```
    def reverse : Roll
      Roll.new @dice.map { |die| die.reverse }
    end

    # Parse the string and return an array of `Dice`
    #
    # see `Dice.consume`
    #
    # The string passed as parameter is consumed, part by part, to create an
    # Array of `Dice`. The string must follow grammar below (case insensitive):
    # ```text
    # - dice = [\d+][d][\d+]
    # - sign = ['+', '-']
    # - sdice = [sign]?[dice]
    # - roll = [sign][dice][sdice]*
    # ```
    def self.parse_str(str : String?, list : Array(Dice) = Array(Dice).new) : Array(Dice)
      return list if str.nil?
      str = str.strip
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

    # Parse the string "str" and returns a new `Roll` object
    # see `#parse_str`
    def self.parse(str : String) : Roll
      return Roll.new(parse_str(str))
    end

    {% for ft in ["min", "max", "test"] %}
    def {{ ft.id }} : Int32
      @dice.reduce(0) { |r, l| r + l.{{ ft.id }} }
    end

    def {{ (ft + "_details").id }} : Array(Int32)
      @dice.map {|dice| dice.{{ (ft + "_details").id }} }.flatten
    end
    {% end %}

    def average : Float64
      @dice.reduce(0.0) { |r, l| r + l.average }
    end

    def average_details : Array(Float64)
      @dice.map { |dice| dice.average_details }.flatten
    end

    def to_s : String
      @dice.reduce(nil) do |l, r|
        if l
          if r.min < 0 && r.max < 0
            l + " - " + r.reverse.to_s
          else
            l + " + " + r.to_s
          end
        else
          r.to_s
        end
      end.to_s
    end

    def ==(right : Roll)
      @dice.size == right.dice.size && @dice.map_with_index{|e, i| right.dice[i] == e }.all?{|e| e == true }
    end

    {% for op in [">", "<", ">=", "<="] %}
    def {{ op.id }}(right : Roll)
      average != right.average ?
      average {{ op.id }} right.average :
      max != right.max ?
      max {{ op.id }} right.max :
      min {{ op.id }} right.min
    end
    {% end %}

    def <=>(right : Roll) : Int32
      average != right.average ?
      average - right.average <=> 0 :
      max != right.max ?
      max - right.max <=> 0 :
      min - right.min <=> 0
    end

    def order!
      @dice.sort!{|a, b| b <=> a }
      self
    end

    def order
      clone.order!
    end

    # let a [1d6, 1d4, 1d6, 2, 2d6]
    # first, we copy it
    # for 1d6 we check evey d6 in the copy, fetch and delete them
    def compact!
      i = 0
      until i >= @dice.size
        # fetch the current dice
        dice_current = @dice[i]
        dice_type = dice_current.die
        dice_count = dice_current.count
        # fetch all dice with the same type
        selected = @dice[(i+1)..(-1)].map_with_index{|d, idx| {d, i + idx} }
        selected.select!{|t| t[0].die == dice_type }
        # delete them from @dice
        deleted = selected.map{|t| @dice.delete_at t[1] }
        # add them to the dice_count and update it
        selected.each{|t| dice_count += t[0].count }
        @dice[i].count = dice_count
        i = i + 1
      end
      self
    end

    def compact
      clone.compact!
    end
  end
end
