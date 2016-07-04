describe Pathfinder::Dice do
  it "initialize" do
    d = Pathfinder::Dice.new 2, 20
    d.should be_a Pathfinder::Dice
    d.min.should eq 2
    d.max.should eq 40
  end
end
