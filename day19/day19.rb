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

  def distances_to_neighbors
    @neighbors.map { |neighbor| distance_to(neighbor) }.sort
  end

  def distance_to(other)
    # determine distance to other point using Pythagorean theorem
    # direction doesn't matter here
    Math.sqrt((0...location.size).map { |i|  (location[i] - other.location[i]) ** 2 }.sum).round(4)
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
  attr_accessor :location

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
  pp(beacons.tally)
  beacons.uniq.size
end

# simple example
s0 = Scanner.new([[0,2,0],[4,1,0],[3,3,0]], 3).scan
s1 = Scanner.new([[-1,-1,0],[-5,0,0],[-2,1,0]], 3).scan
raise unless s0.beacons.map { |b| b.distances_to_neighbors }.sort == s1.beacons.map { |b| b.distances_to_neighbors }.sort

transform, s1_location = s1.location_relative_to(s0)
raise s1_location.inspect unless s1_location == [5,2,0]

# larger example
s0_beacons = [
  [404,-588,-901],
  [528,-643,409],
  [-838,591,734],
  [390,-675,-793],
  [-537,-823,-458],
  [-485,-357,347],
  [-345,-311,381],
  [-661,-816,-575],
  [-876,649,763],
  [-618,-824,-621],
  [553,345,-567],
  [474,580,667],
  [-447,-329,318],
  [-584,868,-557],
  [544,-627,-890],
  [564,392,-477],
  [455,729,728],
  [-892,524,684],
  [-689,845,-530],
  [423,-701,434],
  [7,-33,-71],
  [630,319,-379],
  [443,580,662],
  [-789,900,-551],
  [459,-707,401]
]

s1_beacons = [
  [686,422,578],
  [605,423,415],
  [515,917,-361],
  [-336,658,858],
  [95,138,22],
  [-476,619,847],
  [-340,-569,-846],
  [567,-361,727],
  [-460,603,-452],
  [669,-402,600],
  [729,430,532],
  [-500,-761,534],
  [-322,571,750],
  [-466,-666,-811],
  [-429,-592,574],
  [-355,545,-477],
  [703,-491,-529],
  [-328,-685,520],
  [413,935,-424],
  [-391,539,-444],
  [586,-435,557],
  [-364,-763,-893],
  [807,-499,-711],
  [755,-354,-619],
  [553,889,-390]
]

s2_beacons = [
  [649,640,665],
  [682,-795,504],
  [-784,533,-524],
  [-644,584,-595],
  [-588,-843,648],
  [-30,6,44],
  [-674,560,763],
  [500,723,-460],
  [609,671,-379],
  [-555,-800,653],
  [-675,-892,-343],
  [697,-426,-610],
  [578,704,681],
  [493,664,-388],
  [-671,-858,530],
  [-667,343,800],
  [571,-461,-707],
  [-138,-166,112],
  [-889,563,-600],
  [646,-828,498],
  [640,759,510],
  [-630,509,768],
  [-681,-892,-333],
  [673,-379,-804],
  [-742,-814,-386],
  [577,-820,562]
]

s3_beacons = [
  [-589,542,597],
  [605,-692,669],
  [-500,565,-823],
  [-660,373,557],
  [-458,-679,-417],
  [-488,449,543],
  [-626,468,-788],
  [338,-750,-386],
  [528,-832,-391],
  [562,-778,733],
  [-938,-730,414],
  [543,643,-506],
  [-524,371,-870],
  [407,773,750],
  [-104,29,83],
  [378,-903,-323],
  [-778,-728,485],
  [426,699,580],
  [-438,-605,-362],
  [-469,-447,-387],
  [509,732,623],
  [647,635,-688],
  [-868,-804,481],
  [614,-800,639],
  [595,780,-596]
]

s4_beacons = [
  [727,592,562],
  [-293,-554,779],
  [441,611,-461],
  [-714,465,-776],
  [-743,427,-804],
  [-660,-479,-426],
  [832,-632,460],
  [927,-485,-438],
  [408,393,-506],
  [466,436,-512],
  [110,16,151],
  [-258,-428,682],
  [-393,719,612],
  [-211,-452,876],
  [808,-476,-593],
  [-575,615,604],
  [-485,667,467],
  [-680,325,-822],
  [-627,-443,-432],
  [872,-547,-609],
  [833,512,582],
  [807,604,487],
  [839,-516,451],
  [891,-625,532],
  [-652,-548,-490],
  [30,-46,-14]
]

s0 = Scanner.new(s0_beacons, 12, name: 0).scan
s1 = Scanner.new(s1_beacons, 12, name: 1).scan
s2 = Scanner.new(s2_beacons, 12, name: 2).scan
s3 = Scanner.new(s3_beacons, 12, name: 3).scan
s4 = Scanner.new(s4_beacons, 12, name: 4).scan

s0.location = [0,0,0]
known_scanners = [s0]
unknown_scanners = [s1, s2, s3, s4]

match_scanners(known_scanners, unknown_scanners)
raise s0.location.inspect unless s0.location == [0, 0, 0]
raise s1.location.inspect unless s1.location == [68,-1246,-43]
raise s2.location.inspect unless s2.location == [1105,-1205,1229]
raise s3.location.inspect unless s3.location == [-92,-2380,-20]
raise s4.location.inspect unless s4.location == [-20,-1133,1061]

raise unless unique_beacons([s0, s1, s2, s3, s4]) == 79

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

scanners = parse(File.read("input.txt"))
raise scanners.size.inspect unless scanners.size == 29

puts("start part 1")
scanners[0].location = [0,0,0]
known_scanners = [scanners[0]]
unknown_scanners = scanners[1..]

match_scanners(known_scanners, unknown_scanners)

puts("part 1 - #{unique_beacons(scanners)}")

