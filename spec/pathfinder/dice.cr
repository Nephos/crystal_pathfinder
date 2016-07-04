describe Pathfinder::Dice do
  it "initialize" do
    d = Pathfinder::Dice.new 2, 20
    d.should be_a Pathfinder::Dice
    d.min.should eq 2
    d.max.should eq 40
  end

  it "parse" do
    Pathfinder::Dice.parse("1d6").min.should eq 1
    Pathfinder::Dice.parse("1d6").max.should eq 6
    Pathfinder::Dice.parse("4d6").min.should eq 4
    Pathfinder::Dice.parse("4d6").max.should eq 24
  end

  it "consume" do
    rest = Pathfinder::Dice.consume("1d6+2") do |dice|
      dice.should be_a Pathfinder::Dice
      dice.min.should eq 1
      dice.max.should eq 6
    end
    rest.should eq("+2")
  end
end
