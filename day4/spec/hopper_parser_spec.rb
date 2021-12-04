require "spec_helper"

describe HopperParser do
  let(:input) { "1,2,3,4,5" }
  it "should parse the list of numbers" do
    hopper = subject.parse(input)
    expect(hopper.numbers).to eq([1,2,3,4,5])
  end
end