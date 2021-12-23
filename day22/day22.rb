class Cuboid
  attr_reader :x_range, :y_range, :z_range

  def initialize(x_range, y_range, z_range)
    @x_range = x_range.to_a
    @y_range = y_range.to_a
    @z_range = z_range.to_a

    raise "missing range: #{to_s}" if @x_range.empty? || @y_range.empty? || @z_range.empty?
  end

  def cubes
    @x_range.product(@y_range).product(@z_range)
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
    "x=#{x_range.min}..#{x_range.max}, y=#{y_range.min}..#{y_range.max}, z=#{z_range.min}..#{z_range.max} (size #{size})"
  end

  def include?(x, y, z)
    x_range.include?(x) && y_range.include?(y) && z_range.include?(z)
  end

  def split_if_bisected(other)
    raise if other.nil?
    raise TypeError unless other.is_a?(Cuboid)

    if x_min < other.x_min && x_max > other.x_min
      return split_at(x: other.x_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if x_min < other.x_max && x_max > other.x_max
      return split_at(x: other.x_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    if y_min < other.y_min && y_max > other.y_min
      return split_at(y: other.y_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if y_min < other.y_max && y_max > other.y_max
      return split_at(y: other.y_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    if z_min < other.z_min && z_max > other.z_min
      return split_at(z: other.z_min).map { |c| c.split_if_bisected(other) }.flatten
    end
    if z_min < other.z_max && z_max > other.z_max
      return split_at(z: other.z_max + 1).map { |c| c.split_if_bisected(other) }.flatten
    end

    # puts("returning self #{self.to_s}")
    [self]
  end
end

class Group
  def initialize(cuboids)
    @cuboids = cuboids
    split_overlapping_cuboids
  end

  def cuboids
    @cuboids.dup.freeze
  end

  def <<(new_cuboid)
    # split cuboids when the edge of another cuboid bisects it
    @cuboids << new_cuboid
    split_overlapping_cuboids
  end

  def split_overlapping_cuboids
    # puts("split_overlapping_cuboids (#{@cuboids.size})")
    @cuboids.each do |cuboid1|
      @cuboids.each do |cuboid2|
        next if cuboid1 == cuboid2
        # puts("checking #{cuboid1} vs #{cuboid2}")
        split_cuboids = cuboid1.split_if_bisected(cuboid2)
        if split_cuboids.size > 1
          # puts("split_cuboids: #{split_cuboids.map(&:to_s)}")
          @cuboids = @cuboids - [cuboid1] + split_cuboids
          remove_duplicates
          # puts "splitting again (#{cuboids.size})"
          return split_overlapping_cuboids
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

  def cubes
    @cuboids.flat_map(&:cubes)
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
          raise if matches.size > 1
          index = @cuboids.index(matches[0])
          index.to_s
        else
          " "
        end
      end.join
    end.join("\n")
    grid
  end
end

# splitting x only
cuboid1 = Cuboid.new(10..12, 10..10, 10..10)
cuboid2 = Cuboid.new(11..13, 10..10, 10..10)
group = Group.new([cuboid1, cuboid2])
puts(group.to_s)
puts(group.print_grid)
raise group.cuboids.size.inspect unless group.cuboids.size == 3
raise group.cubes.size.inspect unless group.cubes.size == 4

# splitting x and y

cuboid1 = Cuboid.new(10..12, 10..12, 10..10)
cuboid2 = Cuboid.new(11..13,11..13,10..10)
group = Group.new([cuboid1, cuboid2])
puts(group.to_s)
puts(group.print_grid)
raise group.cubes.size.inspect unless group.cubes.size == 14


cuboid1 = Cuboid.new(10..12, 10..12, 10..12)
cuboid2 = Cuboid.new(11..13,11..13,11..13)
group = Group.new([cuboid1, cuboid2])
raise group.cubes.size.inspect unless group.cubes.size == 46
#
# group = Group.new([cuboid])
# group << cuboid2
# puts(group.print_grid)
# puts(group.to_s)
# puts(group.cubes.size)
