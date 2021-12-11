class Octopus
  attr_reader :value, :neighbors

  def initialize(value)
    raise unless !value.nil? && value.is_a?(Integer)
    @value = value
    @neighbors = []
    @flashed = false
  end

  def increment
    @value = (value == 9 ? 0 : value + 1)
    value == 0
  end
end

class Grid
  attr_reader :octopi

  def initialize(octopi)
    @octopi = octopi
  end

  def size
    octopi.size
  end

  def step
    octopi.each(&:increment)

    flashed = []
    while (true)
      new_flashes = octopi.select { |o| o.value == 0 } - flashed
      break if new_flashes.empty?
      new_flashes.each do |o|
        o.neighbors.select { |n| n.value > 0 }.each(&:increment)
      end
      flashed = [flashed, new_flashes].flatten
    end
    flashed.size
  end

  def current_values
    octopi.map(&:value).map(&:to_s).join
  end
end

def build_grid(input)
  rows = input.split("\n").compact.map { |row| row.chars.compact.map { |value| Octopus.new(value.to_i) } }
  num_rows = rows.size
  num_cols = input.split("\n").compact[0].length

  (0...num_rows).each do |row|
    (0...num_cols).each do |col|
      octopus = rows[row][col]
      octopus.neighbors << rows[row][col-1] if col > 0
      octopus.neighbors << rows[row][col+1] if col < num_cols - 1
      octopus.neighbors << rows[row-1][col] if row > 0
      octopus.neighbors << rows[row+1][col] if row < num_rows - 1
      octopus.neighbors << rows[row-1][col-1] if row > 0 && col > 0
      octopus.neighbors << rows[row+1][col-1] if row < num_rows - 1 && col > 0
      octopus.neighbors << rows[row-1][col+1] if row > 0 && col < num_cols - 1
      octopus.neighbors << rows[row+1][col+1] if row < num_rows - 1 && col < num_cols - 1
    end
  end
  all_octopi = rows.flatten

  raise if all_octopi.any? { |node| node.value.nil? }
  raise if all_octopi.any? { |node| node.neighbors.length < 3 }

  Grid.new(all_octopi)
end

def part1(input, num_steps)
  grid = build_grid(input)
  flashes = 0
  num_steps.times do
    flashes += grid.step
  end
  flashes
end

def part2(input)
  grid = build_grid(input)

  steps = 0
  while (true) do
    steps += 1
    flashes = grid.step
    return steps if flashes == grid.size
  end
end

test_input = <<-INPUT
11111
19991
19191
19991
11111
INPUT
result = part1(test_input, 1)
raise result.inspect if result != 9

test_input = <<-INPUT
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
INPUT
result = part1(test_input, 10)
raise result.inspect if result != 204
result = part1(test_input, 100)
raise result.inspect if result != 1656

result = part2(test_input)
raise result.inspect if result != 195

input = File.read("input.txt")
puts("part 1 - #{part1(input, 100)}")
puts("part 2 - #{part2(input)}")
