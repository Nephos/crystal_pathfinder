describe Rollable::Dice do
  it "initialize" do
    d = Rollable::Dice.new 2, 20
    d.should be_a Rollable::Dice
    d.min.should eq 2
    d.max.should eq 40
    d.average.should eq 21
    expect_raises(Exception) { Rollable::Dice.new 1001, 20 }
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
    d.count.should eq 2
    d.die.min.should eq -20
    d.min.should eq -40
    d.max.should eq -2
    d = Rollable::Dice.new(1, 1).reverse
    d.count.should eq 1
    d.die.min.should eq -1
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
    Rollable::Dice.parse("-1d6").min.should eq -6
    Rollable::Dice.parse("-1d6").max.should eq -1
    Rollable::Dice.parse("-1d6").count.should eq 1
    Rollable::Dice.parse("!1d6").count.should eq 1
    Rollable::Dice.parse("!1d6").min.should eq 1
    Rollable::Dice.parse("!1d6").max.should eq Rollable::Die.new(1..6, true).max
  end

  describe "adjustements" do
    it "initialize" do
      d = Rollable::Dice.new 2, 20, false, 1
      d.should be_a Rollable::Dice
      d.min.should eq 1
      d.max.should eq 20
      d = Rollable::Dice.new 2, 20, false, -1
      d.should be_a Rollable::Dice
      d.min.should eq 1
      d.max.should eq 20
    end

    it "parses keep" do
      Rollable::Dice.parse("2d6k1").should be_a(Rollable::Dice)
      Rollable::Dice.parse("2d6k1").min.should eq 1
      Rollable::Dice.parse("2d6k1").max.should eq 6
      Rollable::Dice.parse("3d6k1").min.should eq 1
      Rollable::Dice.parse("3d6k1").max.should eq 6

      Rollable::Dice.parse("3d6k2").min.should eq 2
      Rollable::Dice.parse("3d6k2").max.should eq 12
      Rollable::Dice.parse("3d6k0").min.should eq 0
      Rollable::Dice.parse("3d6k0").max.should eq 0

      Rollable::Dice.parse("4d6kh1").min.should eq 1
      Rollable::Dice.parse("4d6kh1").max.should eq 6

      Rollable::Dice.parse("4d6kl1").min.should eq 1
      Rollable::Dice.parse("4d6kl1").max.should eq 6

      Rollable::Dice.parse("4d6kl1").count_after_drop.should eq 1
    end

    it "rolls keep dice within bounds" do
      d6kl1 = Rollable::Dice.parse("4d6kl1")
      d6kl1.test.should be <= d6kl1.max
      d6kl1.test.should be >= d6kl1.min

      d6kh2 = Rollable::Dice.parse("4d6kh2")
      d6kh2.test.should be <= d6kh2.max
      d6kh2.test.should be >= d6kh2.min
    end

    it "parses drop" do
      Rollable::Dice.parse("2d6d1").should be_a(Rollable::Dice)
      Rollable::Dice.parse("2d6d1").min.should eq 1
      Rollable::Dice.parse("2d6d1").max.should eq 6
      Rollable::Dice.parse("3d6d1").min.should eq 2
      Rollable::Dice.parse("3d6d1").max.should eq 12

      Rollable::Dice.parse("3d6d2").min.should eq 1
      Rollable::Dice.parse("3d6d2").max.should eq 6
      Rollable::Dice.parse("3d6d3").min.should eq 0
      Rollable::Dice.parse("3d6d3").max.should eq 0

      Rollable::Dice.parse("4d6dh1").min.should eq 3
      Rollable::Dice.parse("4d6dh1").max.should eq 18

      Rollable::Dice.parse("4d6dl1").min.should eq 3
      Rollable::Dice.parse("4d6dl1").max.should eq 18

      Rollable::Dice.parse("4d6dl1").count_after_drop.should eq 3
    end

    it "rolls drop dice within bounds" do
      d6dl1 = Rollable::Dice.parse("4d6dl1")
      d6dl1.test.should be <= d6dl1.max
      d6dl1.test.should be >= d6dl1.min

      d6dh2 = Rollable::Dice.parse("4d6dh2")
      d6dh2.test.should be <= d6dh2.max
      d6dh2.test.should be >= d6dh2.min
    end

    it "correctly calculated the average" do
      # source: https://math.stackexchange.com/a/223248
      Rollable::Dice.parse("2d6kh1").average.round(3).should eq 4.472
      # source: http://onlinedungeonmaster.com/2012/05/24/advantage-and-disadvantage-in-dd-next-the-math/
      Rollable::Dice.parse("2d20d1").average.round(3).should eq 13.825
      Rollable::Dice.parse("2d20dh1").average.round(3).should eq 7.175
    end
  end

  it "parse (error)" do
    expect_raises(Exception) { Rollable::Dice.parse("yolo") }
    expect_raises(Exception) { Rollable::Dice.parse("1d6+1", true) }
    expect_raises(Exception) { Rollable::Dice.parse("--1d4") }
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
    Rollable::Dice.parse("-2d6").to_s.should eq("-2D6")
    Rollable::Dice.parse("2").to_s.should eq("2")
    Rollable::Dice.new(1, Rollable::Die.new(2..2)).to_s.should eq("2")
  end

  it "cmp" do
    # same test in Die
    (Rollable::Dice.parse("2d6") == Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d6") != Rollable::Dice.parse("2d8")).should eq true
    (Rollable::Dice.parse("2d8") > Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d8") >= Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") < Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") <= Rollable::Dice.parse("2d6")).should eq true
    (Rollable::Dice.parse("2d4") <=> Rollable::Dice.parse("2d6") < 0).should eq true
    ((Rollable::Dice.parse("2d6") <=> Rollable::Dice.parse("2d6")) == 0)
    ((Rollable::Dice.parse("3d6") <=> Rollable::Dice.parse("2d6")) > 0)
    ((Rollable::Dice.parse("1d6") <=> Rollable::Dice.parse("2d6")) < 0)
    (Rollable::Dice.parse("2d6") <=> Rollable::Dice.parse("2d4") > 0).should eq true
  end
end
