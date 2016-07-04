describe Pathfinder::Dice do
  it "initialize" do
    d = Pathfinder::Dice.new 2, 20
    d.should be_a Pathfinder::Dice
    d.min.should eq 2
    d.max.should eq 40
  end

  it "consume" do
    str = "1d6+2"
    dice = Array(Pathfinder::Dice).new
    dice << Pathfinder::Dice.consume(str) do |rest|
      rest = rest.to_s
      rest.should eq("+2")
      dice << Pathfinder::Dice.consume(rest[1..-1]) {}
    end
    dice.size.should eq 2
  end
end
