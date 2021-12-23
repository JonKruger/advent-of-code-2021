class Cuboid
  attr_reader :x_range, :y_range, :z_range

  def initialize(x_range, y_range, z_range)
    @x_range = x_range.to_a
    @y_range = y_range.to_a
    @z_range = z_range.to_a
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

end

class Group
  def initialize(cuboids)
    @cuboids = cuboids
  end

  def cuboids
    @cuboids.dup.freeze
  end

  def <<(new_cuboid)
    new_cuboids = [new_cuboid]

    @cuboids = @cuboids.flat_map do |cuboid|
      results = new_cuboids.map do |new_cuboid|
        raise TypeError unless new_cuboid.is_a?(Cuboid)
        intersection = cuboid.x_range.intersection(new_cuboid.x_range)
        existing_split_cuboids = []
        new_split_cuboids = []
        if intersection.any?
          existing_split_cuboids << Cuboid.new(cuboid.x_range - intersection, cuboid.y_range, cuboid.z_range) if (cuboid.x_range - intersection).any?
          existing_split_cuboids << Cuboid.new(intersection, cuboid.y_range, cuboid.z_range)
          new_split_cuboids << Cuboid.new(intersection, new_cuboid.y_range, new_cuboid.z_range) unless new_cuboid.y_range == cuboid.y_range && new_cuboid.z_range == cuboid.z_range
          new_split_cuboids << Cuboid.new(new_cuboid.x_range - intersection, new_cuboid.y_range, new_cuboid.z_range) if (new_cuboid.x_range - intersection).any?
        else
          existing_split_cuboids << cuboid
          new_split_cuboids << new_cuboid
        end
        [existing_split_cuboids, new_split_cuboids]
      end
      existing_split_cuboids = results.map { |r| r[0] }.flatten
      new_cuboids = results.map { |r| r[1] }.flatten
      existing_split_cuboids
    end.flatten
    puts("after x, #{to_s}, new cuboids are #{new_cuboids.inspect}", to_s)
    puts(print_grid)

    @cuboids = @cuboids.flat_map do |cuboid|
      raise TypeError unless cuboid.is_a?(Cuboid)
      results = new_cuboids.map do |new_cuboid|
        raise TypeError unless new_cuboid.is_a?(Cuboid)
        puts("processing #{new_cuboid}")
        intersection = cuboid.y_range.intersection(new_cuboid.y_range) if cuboid.x_range.intersection(new_cuboid.x_range).any?
        existing_split_cuboids = []
        new_split_cuboids = []
        if intersection&.any?
          puts("splitting #{cuboid.to_s} for #{new_cuboid.to_s}- #{intersection}")
          existing_split_cuboids << Cuboid.new(cuboid.x_range, cuboid.y_range - intersection, cuboid.z_range) if (cuboid.y_range - intersection).any?
          existing_split_cuboids << Cuboid.new(cuboid.x_range, intersection, cuboid.z_range)
          new_split_cuboids << Cuboid.new(new_cuboid.x_range, intersection, new_cuboid.z_range) unless new_cuboid.x_range == cuboid.x_range && new_cuboid.z_range == cuboid.z_range
          new_split_cuboids << Cuboid.new(new_cuboid.x_range, new_cuboid.y_range - intersection, new_cuboid.z_range) if (new_cuboid.y_range - intersection).any?
        else
          existing_split_cuboids << cuboid
          new_split_cuboids << new_cuboid
        end
        [existing_split_cuboids, new_split_cuboids]
      end
      existing_split_cuboids = results.map { |r| r[0] }.flatten
      new_cuboids = results.map { |r| r[1] }.flatten
      existing_split_cuboids
    end.flatten
    puts("after y, #{to_s}, new cuboids are #{new_cuboids.inspect}", to_s)

    @cuboids += new_cuboids
    remove_duplicates

    @cuboids
  end

  def remove_duplicates
    result = []
    coordinate_list = []
    cuboids.each do |cuboid|
      coordinates = [cuboid.x_min, cuboid.x_max, cuboid.y_min, cuboid.y_max, cuboid.z_min, cuboid.z_max]
      next if coordinate_list.include?(coordinates)
      result << cuboid
      coordinate_list << coordinates
    end
    @cuboids = result
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
          # raise if matches.size > 1
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

cuboid = Cuboid.new(10..12, 10..12, 10..10)
# raise cuboid.cubes.size.inspect unless cuboid.cubes.size == 27

cuboid2 = Cuboid.new(11..13,11..13,10..10)
group = Group.new([cuboid, cuboid2])
# raise group.cubes.size.inspect unless group.cubes.size == 27 + 19

group = Group.new([cuboid])
group << cuboid2
puts(group.print_grid)
puts(group.to_s)
puts(group.cubes.size)
