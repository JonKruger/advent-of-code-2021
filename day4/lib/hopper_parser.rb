class HopperParser
  def parse(input)
    Hopper.new(input.split(",").compact.map(&:to_i))
  end
end