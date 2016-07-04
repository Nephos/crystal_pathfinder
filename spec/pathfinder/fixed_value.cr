describe Pathfinder::FixedValue do
  it "new" do
    10.times do |i|
      n = i - 5
      f = Pathfinder::FixedValue.new n
      f.should be_a Pathfinder::Die
      f.min.should eq n
      f.max.should eq n
      f.average.should eq n
      f.test.should eq n
    end
  end
end
