require "./dice"
require "./fixed_value"

module Pathfinder
  class Dice
    @count : Int32
    @die : Pathfinder::Die

    def initialize(@count, @die)
    end

    def initialize(@count, die_type : Int32)
      @die = Pathfinder::Die.new(1..die_type)
    end

    #  Returns a Dice parsed from str.
    def self.parse(str : String, strict = true)
      match = str.match(/\A(\d+)(:?(:?d)(\d+))?#{strict ? "\Z" : ""}/i)
      count = match[1]
      die = match[2]?
      return Pathfinder::FixedValue.new(count) if die.nil?
      return Pathfinder::Dice.new(count, die)
    end

    # Returns the size of str.
    #
    # Parse str and yield a Dice.
    def self.parse(str : String)
      yield parse(str)
      return str.size
    end

    def self.consume(str : String)
      str.strip!
      consumed = yield parse(str, false)
      return nil if str.size <= consumed
      return str[consumed..-1].strip
    end

    {% for ft in ["min", "max"] %}
    def {{ ft.id }} : Int32
      @die.{{ ft.id }} * @count
    end
    {% end %}

    def average : Float64
      @die.average * @count
    end

    def test : Int32
      @count.times.reduce(0) { |l, r| l + r.test }
    end
  end
end
