class Cuboid
  attr_reader :x_range, :y_range, :z_range

  def initialize(x_range, y_range, z_range)
    @x_range = Cuboid.limit_range(x_range)
    @y_range = Cuboid.limit_range(y_range)
    @z_range = Cuboid.limit_range(z_range)

    raise "missing range: #{to_s}" if @x_range.min > @x_range.max || @y_range.min > @y_range.max || @z_range.min > @z_range.max
  end

  def self.limit_range(range)
    if range.min < -50
      range = -50..range.max
    end

    if range.max > 50
      range = range.min..50
    end

    range
  end

  def size
    x_range.size * y_range.size * z_range.size
  end

  def x_min
    @x_range.min
  end

  def x_max
    @x_range.max
  end

  def y_min
    @y_range.min
  end

  def y_max
    @y_range.max
  end

  def z_min
    @z_range.min
  end

  def z_max
    @z_range.max
  end

  def split_at(x: nil, y: nil, z: nil)
    # puts("splitting #{self} at [#{x},#{y},#{z}]")
    cuboids = [self]
    if x
      cuboids = cuboids.flat_map { |c| c.split(x_range, x).map { |x_range| Cuboid.new(x_range, c.y_range, c.z_range) } }
    end
    if y
      cuboids = cuboids.flat_map { |c| c.split(y_range, y).map { |y_range| Cuboid.new(c.x_range, y_range, c.z_range) } }
    end
    if z
      cuboids = cuboids.flat_map { |c| c.split(z_range, z).map { |z_range| Cuboid.new(c.x_range, c.y_range, z_range) } }
    end
    # puts("now we have #{cuboids}")
    cuboids
  end

  def split(range, at)
    if range.include?(at)
      [range.min..(at-1), at..range.max]
    else
      [range]
    end
  end

  def to_s
    @to_s ||= "x=#{x_range.min}..#{x_range.max}, y=#{y_range.min}..#{y_range.max}, z=#{z_range.min}..#{z_range.max} (size #{size})"
  end

  def include?(x, y, z)
    x_range.include?(x) && y_range.include?(y) && z_range.include?(z)
  end

  def in_range?(x_range, y_range, z_range)
    self.x_range.min >= x_range.min &&
      self.x_range.max <= x_range.max &&
      self.y_range.min >= y_range.min &&
      self.y_range.max <= y_range.max &&
      self.z_range.min >= z_range.min &&
      self.z_range.max <= z_range.max
  end

  def split_if_bisected(other)
    raise if other.nil?
    raise TypeError unless other.is_a?(Cuboid)

    if x_min < other.x_min && x_max >= other.x_min
      return split_at(x: other.x_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if x_min <= other.x_max && x_max > other.x_max
      return split_at(x: other.x_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    if y_min < other.y_min && y_max >= other.y_min
      return split_at(y: other.y_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if y_min <= other.y_max && y_max > other.y_max
      return split_at(y: other.y_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    if z_min < other.z_min && z_max >= other.z_min
      return split_at(z: other.z_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if z_min <= other.z_max && z_max > other.z_max
      return split_at(z: other.z_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    # puts("returning self #{self.to_s}")
    [self]
  end
end

class Group
  def initialize(cuboids = [])
    @cuboids = cuboids
    split_overlapping_cuboids
    remove_duplicates
  end

  def cuboids
    @cuboids.dup.freeze
  end

  def process_input(input)
    input.split("\n").each do |line|
      match = /^([^\s]+)\sx=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/.match(line)
      if match
        x_min = match[2].to_i
        x_max = match[3].to_i
        y_min = match[4].to_i
        y_max = match[5].to_i
        z_min = match[6].to_i
        z_max = match[7].to_i

        puts("processing #{line}")
        if match[1] == "on"
          turn_on(Cuboid.new(x_min..x_max, y_min..y_max, z_min..z_max))
        elsif match[1] == "off"
          turn_off(Cuboid.new(x_min..x_max, y_min..y_max, z_min..z_max))
        end
      end
    end
  end

  def turn_on(new_cuboid)
    puts("turning on #{new_cuboid.to_s}")
    @cuboids << new_cuboid
    split_overlapping_cuboids
    remove_duplicates
  end

  def turn_off(cuboid)
    puts("turning off #{cuboid.to_s}")
    @cuboids << cuboid
    split_overlapping_cuboids
    remove_duplicates

    # delete all cuboids in the range of the cuboid passed in
    cuboids_to_remove = @cuboids.select { |c| c.in_range?(cuboid.x_range, cuboid.y_range, cuboid.z_range) }
    puts("removing #{cuboids_to_remove.map(&:to_s)}")
    @cuboids = @cuboids - cuboids_to_remove
  end

  def split_overlapping_cuboids(recursion_level = 0)
    @cuboids.each do |cuboid1|
      @cuboids.each do |cuboid2|
        next if cuboid1 == cuboid2
        split_cuboids = cuboid1.split_if_bisected(cuboid2)
        if split_cuboids.size > 1
          @cuboids = @cuboids - [cuboid1] + split_cuboids
          puts "splitting again (size = #{cuboids.size}, recursion_level = #{recursion_level})"
          return split_overlapping_cuboids(recursion_level + 1)
        end
      end
    end
    nil
  end

  def remove_duplicates
    # puts("removing duplicates")
    result = []
    coordinate_list = []
    cuboids.each do |cuboid|
      coordinates = [cuboid.x_min, cuboid.x_max, cuboid.y_min, cuboid.y_max, cuboid.z_min, cuboid.z_max]
      next if coordinate_list.include?(coordinates)
      result << cuboid
      coordinate_list << coordinates
    end
    @cuboids = result
    # puts("we have #{@cuboids.size}")
  end

  def size
    @cuboids.map(&:size).sum
  end

  def to_s
    @cuboids.map { |c| c.to_s }.join("\n")
  end

  def print_grid
    raise "can only print in x,y dimensions" unless @cuboids.map(&:z_range).uniq.size == 1

    x_min = @cuboids.map(&:x_min).min
    x_max = @cuboids.map(&:x_max).max
    y_min = @cuboids.map(&:y_min).min
    y_max = @cuboids.map(&:y_max).max

    grid = (y_min..y_max).map do |y|
      (x_min..x_max).map do |x|
        matches = @cuboids.select { |c| c.include?(x, y, c.z_range.min) }
        if matches.any?
          raise matches.inspect if matches.size > 1
          index = @cuboids.index(matches[0])
          (65 + index).chr # 0 = A, 1 = B, etc.
        else
          " "
        end
      end.join
    end.join("\n")
    grid
  end
end

# splitting x only - case 1
cuboid1 = Cuboid.new(10..12, 10..10, 10..10)
cuboid2 = Cuboid.new(11..13, 10..10, 10..10)
group = Group.new([cuboid1, cuboid2])
# puts(group.to_s)
# puts(group.print_grid)
raise group.cuboids.size.inspect unless group.cuboids.size == 3
raise group.size.inspect unless group.size == 4

# splitting x only - case 2
cuboid1 = Cuboid.new(10..10, 10..10, 10..10)
cuboid2 = Cuboid.new(10..11, 10..10, 10..10)
group = Group.new([cuboid1, cuboid2])
# puts(group.to_s)
puts(group.print_grid)
raise group.cuboids.size.inspect unless group.cuboids.size == 2
raise group.size.inspect unless group.size == 2

# splitting x only - case 3
cuboid1 = Cuboid.new(10..10, 10..10, 10..10)
cuboid2 = Cuboid.new(9..10, 10..10, 10..10)
group = Group.new([cuboid1, cuboid2])
# puts(group.to_s)
puts(group.print_grid)
raise group.cuboids.size.inspect unless group.cuboids.size == 2
raise group.size.inspect unless group.size == 2

# splitting x and y
cuboid1 = Cuboid.new(10..12, 10..12, 10..10)
cuboid2 = Cuboid.new(11..13, 11..13, 10..10)
group = Group.new([cuboid1, cuboid2])
# puts(group.to_s)
# puts(group.print_grid)
raise group.size.inspect unless group.size == 14

# splitting x, y, and z
cuboid1 = Cuboid.new(10..12, 10..12, 10..12)
cuboid2 = Cuboid.new(11..13, 11..13, 11..13)
group = Group.new([cuboid1, cuboid2])
raise group.size.inspect unless group.size == 46

# nested cuboids
cuboid1 = Cuboid.new(10..13, 10..10, 10..10)
cuboid2 = Cuboid.new(11..12, 10..10, 10..10)
group = Group.new([cuboid1, cuboid2])
# puts(group.to_s)
# puts(group.print_grid)
raise group.cuboids.size.inspect unless group.cuboids.size == 3
raise group.size.inspect unless group.size == 4

# nested x, but overlapping y
cuboid1 = Cuboid.new(10..13, 10..12, 10..10)
cuboid2 = Cuboid.new(11..12, 11..13, 10..10)
group = Group.new([cuboid1, cuboid2])
raise group.cuboids.size.inspect unless group.cuboids.size == 7
raise group.size.inspect unless group.size == 14

# turn off - test 1
cuboid_on = Cuboid.new(10..13, 10..10, 10..10)
cuboid_off = Cuboid.new(11..12, 10..10, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 2
raise group.size.inspect unless group.size == 2

# turn off - test 2
cuboid_on = Cuboid.new(10..13, 10..10, 10..10)
cuboid_off = Cuboid.new(9..11, 10..10, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 1
raise group.size.inspect unless group.size == 2

# turn off - test 3
cuboid_on = Cuboid.new(10..13, 10..10, 10..10)
cuboid_off = Cuboid.new(11..13, 10..10, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 1
raise group.size.inspect unless group.size == 1

# turn off - test 4
cuboid_on = Cuboid.new(10..13, 10..10, 10..10)
cuboid_off = Cuboid.new(10..13, 10..10, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 0
raise group.size.inspect unless group.size == 0

# turn off - test 5
cuboid_on = Cuboid.new(10..13, 10..10, 10..10)
cuboid_off = Cuboid.new(11..14, 10..10, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 1
raise group.size.inspect unless group.size == 1

# turn off - test 6
cuboid_on = Cuboid.new(10..12, 10..12, 10..10)
cuboid_off = Cuboid.new(11..13, 11..13, 10..10)
group = Group.new()
group.turn_on(cuboid_on)
group.turn_off(cuboid_off)
raise group.cuboids.size.inspect unless group.cuboids.size == 3
raise group.size.inspect unless group.size == 5

# example from requirements - x & y
group = Group.new()
group.process_input("on x=10..12,y=10..12,z=10..10")
puts(group.print_grid)
raise group.size.inspect unless group.size == 9
group.process_input("on x=11..13,y=11..13,z=10..10")
puts(group.print_grid)
raise group.size.inspect unless group.size == 14
group.process_input("off x=9..11,y=9..11,z=10..10")
puts(group.print_grid)
raise group.size.inspect unless group.size == 10
group.process_input("on x=10..10,y=10..10,z=10..10")
puts(group.print_grid)
raise group.size.inspect unless group.size == 11

# example from requirements
group = Group.new()
group.process_input("on x=10..12,y=10..12,z=10..12")
raise group.size.inspect unless group.size == 27
group.process_input("on x=11..13,y=11..13,z=11..13")
raise group.size.inspect unless group.size == 27 + 19
group.process_input("off x=9..11,y=9..11,z=9..11")
raise group.size.inspect unless group.size == 27 + 19 - 8
group.process_input("on x=10..10,y=10..10,z=10..10")
raise group.size.inspect unless group.size == 27 + 19 - 8 + 1

# ignore coordinates < -50 or > 50
group = Group.new()
group.process_input("on x=-541..392,y=-850..492,z=-274..787")
raise group.size.inspect unless group.size == 101**3

# larger example from requirements
input = <<-INPUT
on x=-20..26,y=-36..17,z=-47..7
on x=-20..33,y=-21..23,z=-26..28
on x=-22..28,y=-29..23,z=-38..16
on x=-46..7,y=-6..46,z=-50..-1
on x=-49..1,y=-3..46,z=-24..28
on x=2..47,y=-22..22,z=-23..27
on x=-27..23,y=-28..26,z=-21..29
on x=-39..5,y=-6..47,z=-3..44
on x=-30..21,y=-8..43,z=-13..34
on x=-22..26,y=-27..20,z=-29..19
off x=-48..-32,y=26..41,z=-47..-37
on x=-12..35,y=6..50,z=-50..-2
off x=-48..-32,y=-32..-16,z=-15..-5
on x=-18..26,y=-33..15,z=-7..46
off x=-40..-22,y=-38..-28,z=23..41
on x=-16..35,y=-41..10,z=-47..6
off x=-32..-23,y=11..30,z=-14..3
on x=-49..-5,y=-3..45,z=-29..18
off x=18..30,y=-20..-8,z=-3..13
on x=-41..9,y=-7..43,z=-33..15
on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
on x=967..23432,y=45373..81175,z=27513..53682
INPUT
group = Group.new()
group.process_input(input)
raise group.size.inspect unless group.size == 590784
