describe Rollable::Roll do
  it "initialize" do
    r = Rollable::Roll.new [
      Rollable::Dice.new(1, 20),
      Rollable::Dice.new(1, Rollable::FixedValue.new 4),
    ]
    r.should be_a Rollable::Roll
    r.min.should eq 5
    r.max.should eq 24
    r.average.should eq 14.5
    10.times do
      (5..24).includes?(r.test).should eq true
    end
  end

  it "test (details)" do
    r = Rollable::Roll.new [Rollable::Dice.new(2, 6), Rollable::Dice.new(1, 4)]
    r.min_details.should eq([1, 1, 1])
    r.max_details.should eq([6, 6, 4])
    r.average_details.should eq([3.5, 3.5, 2.5])
    10.times do
      t = r.test_details
      (1..6).includes?(t[0]).should eq true
      (1..6).includes?(t[1]).should eq true
      (1..4).includes?(t[2]).should eq true
    end
  end

  it "parse (simple)" do
    (r1 = Rollable::Roll.parse("2d6+4")).should be_a(Rollable::Roll)
    r1.average.should eq 11
    (r2 = Rollable::Roll.parse("1")).should be_a(Rollable::Roll)
    r2.average.should eq 1
    (r3 = Rollable::Roll.parse("1d6")).should be_a(Rollable::Roll)
    r3.average.should eq 3.5
    (r4 = Rollable::Roll.parse("1d6+1")).should be_a(Rollable::Roll)
    r4.average.should eq 4.5
    (r5 = Rollable::Roll.parse("1d6-1")).should be_a(Rollable::Roll)
    r5.average.should eq 2.5
    r1.should be_a(Rollable::Roll)
    r1.min.should eq 6
    r1.max.should eq 16
  end

  it "parse (error)" do
    expect_raises { Rollable::Roll.parse("yolo") }
  end

  it "parse (more)" do
    (r = Rollable::Roll.parse(" 1d6 - 1 + 2 - 1d6 ")).should be_a(Rollable::Roll)
    r.min.should eq -4
    r.max.should eq 6
    r.average.should eq 1
  end

  it "to_s" do
    Rollable::Roll.parse(" 1d6 - 1 + 2 - 1d6 ").to_s.should eq("1D6 - 1 + 2 - 1D6")
  end

  it "cmp" do
    r1 = Rollable::Roll.parse("2d6+1")
    r2 = Rollable::Roll.parse("2d6+2")
    r3 = Rollable::Roll.parse("2d8")
    # same tests than Dice and Die
    (r1 == r1).should eq true
    (r1 == r2).should eq false
    (r1 == r3).should eq false

    (r2 == r3).should eq false
    (r2 >= r3).should eq false
    (r2 <= r3).should eq true
    (r2 <=> r3).should eq false
  end
end
