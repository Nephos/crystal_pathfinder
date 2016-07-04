module Pathfinder
  class Die

    @faces : Range(Int32, Int32)

    def initialize(@faces)
    end

    def initialize(nb_faces : Int32)
      @faces = 1..nb_faces
    end

    def average : Float64
      @faces.reduce{|r, l| r + l }.to_f64 / @faces.size
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

  end
end
