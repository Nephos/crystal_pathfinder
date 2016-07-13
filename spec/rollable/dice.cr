describe Rollable::Dice do
  it "initialize" do
    d = Rollable::Dice.new 2, 20
    d.should be_a Rollable::Dice
    d.min.should eq 2
    d.max.should eq 40
    d.average.should eq 21
  end

  it "details" do
    d = Rollable::Dice.new 2, 6
    d.min_details.should eq [1, 1]
    d.max_details.should eq [6, 6]
    d.average_details.should eq [3.5, 3.5]
    10.times do
      d.test_details.each { |v| (1..6).includes?(v).should eq(true) }
    end
  end

  it "reverse" do
    d = Rollable::Dice.new(2, 20).reverse
    d.min.should eq -40
    d.max.should eq -2
    d = Rollable::Dice.new(1, 1).reverse
    d.min.should eq -1
    d.max.should eq -1
  end

  it "parse (simple)" do
    Rollable::Dice.parse("1d6").should be_a(Rollable::Dice)
    Rollable::Dice.parse("1d6").min.should eq 1
    Rollable::Dice.parse("1d6").max.should eq 6
    Rollable::Dice.parse("4d6").min.should eq 4
    Rollable::Dice.parse("4d6").max.should eq 24
    Rollable::Dice.parse("1d6+1", false).min.should eq 1
  end

  it "parse (error)" do
    expect_raises { Rollable::Dice.parse("yolo") }
    expect_raises { Rollable::Dice.parse("1d6+1", true) }
  end

  it "consume" do
    rest = Rollable::Dice.consume("1d6+2") do |dice|
      dice.should be_a Rollable::Dice
      dice.min.should eq 1
      dice.max.should eq 6
    end
    rest.should eq("+2")
  end

  it "to_s" do
    Rollable::Dice.parse("2d6").to_s.should eq("2D6")
    Rollable::Dice.parse("2").to_s.should eq("2")
  end

  it "cmp" do
    # same test in Die
    (Rollable::Dice.parse("2d6") == Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d6") != Rollable::Dice.parse("2d8")).should eq true
    (Rollable::Dice.parse("2d8") > Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d8") >= Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") < Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") <= Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") <=> Rollable::Dice.parse("2d6")).should eq true
  end
end
