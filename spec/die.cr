describe Pathfinder::Die do
  it "initialize" do
    Pathfinder::Die.new(1..20).should be_a(Pathfinder::Die)
    Pathfinder::Die.new(10..20).should be_a(Pathfinder::Die)
    Pathfinder::Die.new(20).should be_a(Pathfinder::Die)
  end

  it "min max" do
    Pathfinder::Die.new(1..1).min.should eq 1
    Pathfinder::Die.new(1..1).max.should eq 1
    Pathfinder::Die.new(1..20).min.should eq 1
    Pathfinder::Die.new(1..20).max.should eq 20
  end

  it "test" do
    100.times do
      min = rand 1..10
      max = rand min..20
      ((min..max).includes? Pathfinder::Die.new(min..max).test).should eq(true)
    end
  end
end
