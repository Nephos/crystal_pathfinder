describe Pathfinder::Dice do
  it "initialize" do
    d = Pathfinder::Dice.new 2, 20
    d.should be_a Pathfinder::Dice
    d.min.should eq 2
    d.max.should eq 40
  end

  it "reverse" do
    d = Pathfinder::Dice.new(2, 20).reverse
    d.min.should eq -40
    d.max.should eq -2
    d = Pathfinder::Dice.new(1, 1).reverse
    d.min.should eq -1
    d.max.should eq -1
  end

  it "parse (simple)" do
    Pathfinder::Dice.parse("1d6").should be_a(Pathfinder::Dice)
    Pathfinder::Dice.parse("1d6").min.should eq 1
    Pathfinder::Dice.parse("1d6").max.should eq 6
    Pathfinder::Dice.parse("4d6").min.should eq 4
    Pathfinder::Dice.parse("4d6").max.should eq 24
    Pathfinder::Dice.parse("1d6+1", false).min.should eq 1
  end

  it "parse (error)" do
    expect_raises { Pathfinder::Dice.parse("yolo") }
    expect_raises { Pathfinder::Dice.parse("1d6+1", true) }
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
