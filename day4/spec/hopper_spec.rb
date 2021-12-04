require "spec_helper"

describe Hopper do
  subject { Hopper.new([1,2,3,4,5]) }

  context "drawing" do
    it "should take the first number from the list" do
      expect(subject.draw).to eq(1)
      expect(subject.draw).to eq(2)
      expect(subject.draw).to eq(3)
      expect(subject.draw).to eq(4)
      expect(subject.draw).to eq(5)
    end

    it "should contain the remaining numbers after a draw" do
      subject.draw
      expect(subject.numbers).to eq([2,3,4,5])
    end
  end

  context "empty?" do
    it "should return false when there are numbers left" do
      4.times { subject.draw }
      expect(subject.empty?).to be false
    end

    it "should return true when there are no numbers left" do
      5.times { subject.draw }
      expect(subject.empty?).to be true
    end
  end
end