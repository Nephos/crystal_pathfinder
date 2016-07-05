describe Rollable::Die do
  it "initialize" do
    Rollable::Die.new(1..20).should be_a(Rollable::Die)
    Rollable::Die.new(10..20).should be_a(Rollable::Die)
    Rollable::Die.new(20).should be_a(Rollable::Die)
  end

  it "min, max, average" do
    Rollable::Die.new(1..1).min.should eq 1
    Rollable::Die.new(1..1).max.should eq 1
    Rollable::Die.new(1..1).average.should eq 1
    Rollable::Die.new(1..20).min.should eq 1
    Rollable::Die.new(1..20).max.should eq 20
    Rollable::Die.new(1..20).average.should eq 10.5
  end

  it "test" do
    100.times do
      min = rand 1..10
      max = rand min..20
      ((min..max).includes? Rollable::Die.new(min..max).test).should eq(true)
    end
  end

  it "reverse" do
    Rollable::Die.new(1..20).reverse.min.should eq -20
    Rollable::Die.new(1..20).reverse.max.should eq -1
    Rollable::Die.new(1..1).reverse.min.should eq -1
    Rollable::Die.new(1..1).reverse.max.should eq -1
  end

  it "to_s" do
    Rollable::Die.new(1..20).to_s.should eq "D20"
    Rollable::Die.new(2..2).to_s.should eq "2"
    Rollable::Die.new(2..4).to_s.should eq "D(2,4)"
  end
end
