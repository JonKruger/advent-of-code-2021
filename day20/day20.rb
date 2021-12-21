class Pixel
  attr_reader :location
  attr_accessor :neighbors

  def initialize(location, lit)
    @location = location
    @lit = lit
  end

  def lit?
    @lit
  end
end

class Image
  attr_reader :pixels
  def initialize
    @pixels = {}
  end

  def lit_pixels_count
    pixels.select { |_, p| p.lit? }.size
  end

  def [](x, y)
    @pixels[[x, y]]
  end

  def add_pixel(pixel)
    raise "pixel already exists at #{pixel.location}" if @pixels.include?(pixel.location)
    @pixels[pixel.location] = pixel
  end

  def expand
    min_x = pixels.values.map { |p| p.location[0] }.min
    max_x = pixels.values.map { |p| p.location[0] }.max
    min_y = pixels.values.map { |p| p.location[1] }.min
    max_y = pixels.values.map { |p| p.location[1] }.max

    new_locations = []

    # top row
    new_locations = new_locations + ((min_x-1)..(max_x+1)).map { |x| [x, min_y - 1]}

    # bottom row
    new_locations = new_locations + ((min_x-1)..(max_x+1)).map { |x| [x, max_y + 1]}

    # left column
    new_locations = new_locations + ((min_y)..(max_y)).map { |y| [min_x - 1, y] }

    # right column
    new_locations = new_locations + ((min_y)..(max_y)).map { |y| [max_x + 1, y] }

    new_locations.each do |location|
      pixels[location] = Pixel.new(location, false)
    end
    set_neighbors
  end

  def shrink
    min_x = pixels.values.map { |p| p.location[0] }.min
    max_x = pixels.values.map { |p| p.location[0] }.max
    min_y = pixels.values.map { |p| p.location[1] }.min
    max_y = pixels.values.map { |p| p.location[1] }.max
    @pixels = pixels.select { |location, pixel| ![min_x, max_x].include?(location[0]) && ![min_y, max_y].include?(location[1]) }
    set_neighbors
  end

  def set_neighbors
    pixels.values.each do |pixel|
      pixel_neighbor_locations = neighbor_locations(pixel.location)
      pixel.neighbors = pixel_neighbor_locations.map { |location| pixels[location] }.compact
    end
  end

  def neighbor_locations(center_location)
    neighbors = (center_location[0]-1..center_location[0]+1).flat_map do |x|
      (center_location[1]-1..center_location[1]+1).map do |y|
        [x, y]
      end
    end
    neighbors.delete(center_location)
    neighbors
  end

  def enhance(algorithm)
    start = Time.now
    2.times { expand }
    # print

    new_image = Image.new

    min_x = pixels.values.map { |p| p.location[0] }.min
    max_x = pixels.values.map { |p| p.location[0] }.max
    min_y = pixels.values.map { |p| p.location[1] }.min
    max_y = pixels.values.map { |p| p.location[1] }.max

    ((min_x+1)..(max_x-1)).each do |x|
      ((min_y+1)..(max_y-1)).each do |y|
        pixel = self[x,y]
        pixel_grid = pixel.neighbors[0..3] + [pixel] + pixel.neighbors[4..]
        algorithm_index = pixel_grid.map { |n| n.lit? ? "1" : "0" }.join.to_i(2)
        # puts("#{pixel.location} - #{algorithm_index} - #{pixel.neighbors.map { |n| n.lit? ? "1" : "0" }.join}")
        new_image.add_pixel(Pixel.new([x,y], algorithm[algorithm_index]))
      end
    end

    puts("enhanced in #{Time.now - start} seconds")
    new_image
  end

  def print
    output_lines = []

    min_x = pixels.values.map { |p| p.location[0] }.min
    max_x = pixels.values.map { |p| p.location[0] }.max
    min_y = pixels.values.map { |p| p.location[1] }.min
    max_y = pixels.values.map { |p| p.location[1] }.max
    (min_x..max_x).each do |x|
      output_lines << (min_y..max_y).map { |y| self[x,y].lit? ? "#" : "." }.join
    end
    output = output_lines.join("\n")
    puts(output)
    puts
    output
  end
end

def parse(input)
  algorithm = input.split("\n")[0].chars.map { |c| c == "#" }
  raise unless algorithm.size == 512

  image = Image.new
  lines = input.split("\n")[2..].select { |line| line.size > 0 }
  lines.each_with_index do |line, row_index|
    line.chars.each_with_index do |c, col_index|
      raise unless ["#","."].include?(c)
      pixel = Pixel.new([row_index, col_index], c == "#")
      image.add_pixel(pixel)
    end
  end
  image.set_neighbors

  [algorithm, image]
end

# test parsing
algorithm, image = parse(File.read("test_input.txt"))
raise image.pixels.size.inspect unless image.pixels.size == 25
raise image.lit_pixels_count.inspect unless image.lit_pixels_count == 10
raise image[0,0].location.inspect unless image[0,0].location == [0,0]
raise image[1,1].neighbors.size.inspect unless image[1,1].neighbors.size == 8
# image.print

# test shrinking
algorithm, image = parse(File.read("test_input.txt"))
raise unless image.pixels.size == 25
image.shrink
raise image.pixels.size.inspect unless image.pixels.size == 9


# test expanding the image
algorithm, image = parse(File.read("test_input.txt"))
image.expand
raise image.pixels.size.inspect unless image.pixels.size == 49
raise image.lit_pixels_count.inspect unless image.lit_pixels_count == 10
# image.print

# test enhancing
expected_output = <<-OUTPUT
.##.##.
#..#.#.
##.#..#
####..#
.#..##.
..##..#
...#.#.
OUTPUT
algorithm, image = parse(File.read("test_input.txt"))
image = image.enhance(algorithm)
puts(image)
raise unless image.print == expected_output.strip

# test enhancing twice with infinite space
expected_output = <<-OUTPUT
.......#.
.#..#.#..
#.#...###
#...##.#.
#.....#.#
.#.#####.
..#.#####
...##.##.
....###..
OUTPUT
algorithm, image = parse(File.read("test_input.txt"))
image = image.enhance(algorithm)
image.print
image = image.enhance(algorithm)
image.print
raise image.lit_pixels_count.inspect unless image.lit_pixels_count == 35

input = File.read("input.txt")
algorithm, image = parse(input)
8.times { image.expand }
image = image.enhance(algorithm)
2.times { image.shrink }
image.print
image = image.enhance(algorithm)
6.times { image.shrink }
image.print
puts("part 1 - #{image.lit_pixels_count}")

input = File.read("input.txt")
algorithm, image = parse(input)
25.times do
  8.times { image.expand }
  image = image.enhance(algorithm)
  2.times { image.shrink }
  image = image.enhance(algorithm)
  6.times { image.shrink }
end
image.print
puts("part 2 - #{image.lit_pixels_count}")
