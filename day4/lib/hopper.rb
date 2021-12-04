class Hopper
  def initialize(numbers)
    @numbers = numbers
  end

  def numbers
    @numbers.dup.freeze
  end

  def draw
    @numbers.shift
  end

  def empty?
    @numbers.size == 0
  end
end