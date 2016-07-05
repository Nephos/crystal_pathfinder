describe Rollable::Dice do
  it "initialize" do
    d = Rollable::Dice.new 2, 20
    d.should be_a Rollable::Dice
    d.min.should eq 2
    d.max.should eq 40
    d.average.should eq 21
  end
end
