describe Pathfinder::Roll do
  it "initialize" do
    r = Pathfinder::Roll.new [
      Pathfinder::Dice.new(1, 20),
      Pathfinder::Dice.new(1, Pathfinder::FixedValue.new 4),
    ]
    r.should be_a Pathfinder::Roll
    r.min.should eq 5
    r.max.should eq 24
    r.average.should eq 14.5
  end
end
