# find distance between each beacon and every other known beacon
# match up the beacon distances to determine matching beacons
# figure out how to transform the points

class Beacon
  attr_reader :location, :scanner
  attr_accessor :neighbors

  def initialize(location, scanner)
    @location = location
    @scanner = scanner
    @neighbors = []
  end

  def dimensions
    @location.size
  end

  def transform_to(other, coordinate_transform = nil)
    if coordinate_transform
      raise TypeError unless coordinate_transform.is_a?(Transform)
    end
    self.class.transform(location, other.location, coordinate_transform)
  end

  def self.transform(location, other_location, coordinate_transform = nil)
    other_location = coordinate_transform.call(other_location) if coordinate_transform
    (0...location.size).map { |i| location[i] - other_location[i] }
  end

  def transform!(transform)
    @location = transform.call(location)
  end
end

class Transform
  attr_reader :dimension_transform, :value_transform

  def initialize(dimension_transform, value_transform, function)
    @dimension_transform = dimension_transform
    @value_transform = value_transform
    @function = function
  end

  def call(location)
    @function.call(location)
  end
end

class Scanner
  attr_reader :beacons, :name, :beacon_array, :num_dimensions
  attr_accessor :location, :common_beacon_count

  def initialize(beacon_array = [], common_beacon_count = 2, name: nil, num_dimensions: 3)
    @beacon_array = beacon_array
    @common_beacon_count = common_beacon_count
    @name = name
    @num_dimensions = num_dimensions
  end

  def scan
    @beacons = @beacon_array.map { |location| Beacon.new(location, self) }
    @beacons.each do |beacon|
      beacon.neighbors = @beacons.select { |other| other != beacon }
    end
    self
  end

  def transform!(transform)
    @beacons.each { |beacon| beacon.transform!(transform) }
  end

  def location_relative_to(other_scanner)
    results = []
    coordinate_transforms.each do |transform|
      diffs = []
      beacons.each do |my_beacon|
        transformed_location = transform.call(my_beacon.location)
        other_scanner.beacons.each do |their_beacon|
          diffs << (0...transformed_location.size).map { |i| their_beacon.location[i] - transformed_location[i] }
        end
      end

      lateral_transform = diffs.tally.select { |k,v| v >= @common_beacon_count }.map { |k,v| k }.uniq.first
      results << [transform, lateral_transform] if lateral_transform
    end
    # puts("multiple transforms - #{results.inspect}") if results.size > 1
    results.first
  end

  def coordinate_transforms
    @coordinate_transforms ||=
      begin
        transforms = []
        dimension_transforms = (0...num_dimensions).to_a.permutation(3).to_a
        value_transforms = (0...(num_dimensions - 1)).inject([1,-1]) { |result, _| result.product([1,-1]).map(&:flatten) }

        dimension_transforms.each do |dimension_transform|
          value_transforms.each do |value_transform|
            function = lambda do |location|
              raise TypeError unless location.is_a?(Array)
              (0...num_dimensions).map do |i|
                location[dimension_transform[i]] * value_transform[i]
              end
            end
            transforms << Transform.new(dimension_transform, value_transform, function)
          end
        end
        transforms
      end
  end
end

def match_one_scanner(known_scanners, unknown_scanners)
  known_scanners.each do |known|
    unknown_scanners.each do |unknown|
      transform, lateral_transform = unknown.location_relative_to(known)
      if transform
        puts("match between #{known.name} and #{unknown.name}")
        unknown.transform!(transform)
        unknown.location = (0...3).map { |i| lateral_transform[i] + known.location[i] }
        known_scanners << unknown
        unknown_scanners.delete(unknown)
        return true
      end
    end
  end
  return false
end

def match_scanners(known_scanners, unknown_scanners)
  while (match_one_scanner(known_scanners, unknown_scanners)) do
    puts("#{unknown_scanners.size} unknown scanners remaining")
  end
end

def unique_beacons(scanners)
  beacons = scanners.flat_map do |scanner|
    scanner.beacons.map do |b|
      (0...b.dimensions).map { |i| b.location[i] + scanner.location[i] }
    end
  end
  beacons.uniq.size
end

def parse(input)
  scanners = []
  lines = input.split("\n").compact.select { |line| line.size > 0 }
  current_scanner = nil

  lines.each do |line|
    match = /--- scanner ([0-9]+) ---/.match(line)
    if match
      current_scanner = Scanner.new(name: match[1])
      scanners << current_scanner
    else
      location = line.split(",").map(&:to_i)
      raise line.inspect if location.size != 3
      current_scanner.beacon_array << location
    end
  end
  scanners.each(&:scan)
  scanners
end

# simple example
s0 = Scanner.new([[0,2,0],[4,1,0],[3,3,0]], 3).scan
s1 = Scanner.new([[-1,-1,0],[-5,0,0],[-2,1,0]], 3).scan

transform, s1_location = s1.location_relative_to(s0)
raise s1_location.inspect unless s1_location == [5,2,0]

# larger example
scanners = parse(File.read("test_input.txt"))
scanners.each { |s| s.common_beacon_count = 12 }
scanners[0].location = [0,0,0]
known_scanners = [scanners[0]]
unknown_scanners = scanners[1..]

match_scanners(known_scanners, unknown_scanners)
raise scanners[0].location.inspect unless scanners[0].location == [0, 0, 0]
raise scanners[1].location.inspect unless scanners[1].location == [68,-1246,-43]
raise scanners[2].location.inspect unless scanners[2].location == [1105,-1205,1229]
raise scanners[3].location.inspect unless scanners[3].location == [-92,-2380,-20]
raise scanners[4].location.inspect unless scanners[4].location == [-20,-1133,1061]

raise unless unique_beacons(scanners) == 79

puts("start part 1")
scanners = parse(File.read("input.txt"))
raise scanners.size.inspect unless scanners.size == 29
scanners.each { |s| s.common_beacon_count = 12 }
scanners[0].location = [0,0,0]
known_scanners = [scanners[0]]
unknown_scanners = scanners[1..]

match_scanners(known_scanners, unknown_scanners)

puts("part 1 - #{unique_beacons(scanners)}")

manhattan_distance = scanners.product(scanners).map do |one, two|
  (one.location[0] - two.location[0]).abs +
    (one.location[1] - two.location[1]).abs +
    (one.location[2] - two.location[2]).abs
end.max
puts("part 2 - #{manhattan_distance }")
