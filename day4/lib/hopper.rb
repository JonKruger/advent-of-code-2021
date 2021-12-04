class Hopper
  def initialize(numbers)
    @numbers = numbers
  end

  def numbers
    @numbers.dup.freeze
  end
end