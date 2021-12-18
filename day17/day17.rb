class Result < Struct.new(:x_velocity, :y_velocity, :x_targets, :y_targets, :coordinates)
  def highest_y
    @highest_y ||= coordinates.map { |x, y| y}.max
  end

  def hit?
    coordinates.any? { |x, y| x_targets.include?(x) && y_targets.include?(y) }
  end
end

def cumsum(array)
  array.inject([]) { |x, y| x + [(x.last || 0) + y] }
end

def find_possible_x_velocities_for_upward_shot(x_targets)
  x = 1
  valid_options = []
  while (true) do
    max_x = (x * (x + 1)) / 2
    valid_options << x if x_targets.include?(max_x)
    break if max_x > x_targets.max
    x += 1
  end
  valid_options
end

def fire(x_velocity, y_velocity, x_targets, y_targets)
  coordinates = []
  while (true) do
    x_position = (coordinates.any? ? coordinates.last[0] : 0) + [0, x_velocity - coordinates.size].max
    y_position = (coordinates.any? ? coordinates.last[1] : 0) + (y_velocity - coordinates.size)
    coordinates << [x_position, y_position]

    # stop if we've shot past the target
    break if x_position > x_targets.max || y_position < y_targets.min
  end
  Result.new(x_velocity, y_velocity, x_targets, y_targets, coordinates)
end

def find_y_velocity_that_goes_the_highest(x_possibilities, x_targets, y_targets)
  highest_y = nil
  x_possibilities.each do |x_velocity|
    y_velocity = 0
    while (true) do
      result = fire(x_velocity, y_velocity, x_targets, y_targets)

      # since velocity always decreases by 1, it will always go through 0,
      # so stop if the next step after 0 will miss the entire range
      break if y_velocity > -y_targets.min

      if result.hit?
        highest_y = [highest_y, result.highest_y].compact.max
      end

      y_velocity = y_velocity + 1
    end
  end
  highest_y
end

def max_y(x_range, y_range)
  raise TypeError unless x_range.is_a?(Range)
  raise TypeError unless y_range.is_a?(Range)

  x_targets = x_range.to_a
  y_targets = y_range.to_a

  x_possibilities = find_possible_x_velocities_for_upward_shot(x_targets)
  find_y_velocity_that_goes_the_highest(x_possibilities, x_targets, y_targets)
end

def possible_shots(x_targets, y_targets)
  potential_x_velocities = (0..x_targets.max).to_a
  potential_y_velocities = (-y_targets.map(&:abs).max..y_targets.map(&:abs).max).to_a
  potential_x_velocities.product(potential_y_velocities).map do |x, y|
    fire(x, y, x_targets, y_targets)
  end.select { |result| result.hit? }.size
end

result = find_possible_x_velocities_for_upward_shot((20..30).to_a)
raise result.inspect if result != [6,7]


result = max_y((20..30), (-10..-5))
raise result.inspect if result != 45

result = possible_shots((20..30), (-10..-5))
raise result.inspect if result != 112

puts("part 1 - #{max_y((207..263), (-115..-63))}")
puts("part 2 - #{possible_shots((207..263), (-115..-63))}")
