class Cave
  attr_reader :name, :connections

  def initialize(name)
    @name = name
    @connections = []
  end

  def start?
    name == "start"
  end

  def end?
    name == "end"
  end

  def small?
    /[a-z]+/.match(name)
  end
end

class Path
  attr_reader :route
  def initialize(route, visit_one_small_cave_twice)
    raise route.inspect unless route.is_a?(Array) && route.all? { |child| child.is_a?(Cave) }
    @route = route
    @visit_one_small_cave_twice = visit_one_small_cave_twice
  end

  def current_cave
    @route.last
  end

  def paths
    if available_connections.any?
      available_connections.map do |c|
        new_route = (@route + [c]).flatten
        Path.new(new_route, @visit_one_small_cave_twice).paths
      end.flatten
    else
      [self]
    end

  end

  def available_connections
    return [] if current_cave.end?
    @available_connections ||= current_cave.connections.select do |cave|
      if cave.start?
        false
      elsif !@visit_one_small_cave_twice && cave.small? && @route.include?(cave)
        false
      elsif @visit_one_small_cave_twice && cave.small? && @route.include?(cave) && @route.select { |cave| cave.small? }.tally.values.max == 2
        false
      else
        true
      end
    end
  end

  def completed?
    current_cave.end?
  end
end

class CaveSystem
  def initialize(caves_hash, visit_one_small_cave_twice)
    @caves_hash = caves_hash
    @visit_one_small_cave_twice = visit_one_small_cave_twice
  end

  def paths
    start = @caves_hash["start"]
    Path.new([start], @visit_one_small_cave_twice).paths
  end
end


def parse_input(input, visit_one_small_cave_twice)
  parsed_lines = input.split("\n").compact.map { |line| line.split("-") }
  cave_names = parsed_lines.flatten.uniq

  caves = {}
  cave_names.each do |name|
    caves[name] = Cave.new(name)
  end

  parsed_lines.each do |line|
    caves[line[0]].connections << caves[line[1]]
    caves[line[1]].connections << caves[line[0]]
  end

  CaveSystem.new(caves, visit_one_small_cave_twice)
end

def process(input, visit_one_small_cave_twice)
  cave_system = parse_input(input, visit_one_small_cave_twice)
  completed_paths = cave_system.paths.select { |path| path.completed? }
  # completed_paths.map { |path| path.route.map(&:name) }.sort.each { |path| puts(path.join(",")) }
  completed_paths.size
end



test_input1 = <<-INPUT
start-A
start-b
A-c
A-b
b-d
A-end
b-end
INPUT
result = process(test_input1, false)
raise result.inspect if result != 10

test_input2 = <<-INPUT
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
INPUT
result = process(test_input2, false)
raise result.inspect if result != 226

input = <<-INPUT
re-js
qx-CG
start-js
start-bj
qx-ak
js-bj
ak-re
CG-ak
js-CG
bj-re
ak-lg
lg-CG
qx-re
WP-ak
WP-end
re-lg
end-ak
WP-re
bj-CG
qx-start
bj-WP
JG-lg
end-lg
lg-iw
INPUT
puts("part 1 - #{process(input, false)}")

result = process(test_input1, true)
raise result.inspect if result != 36

result = process(test_input2, true)
raise result.inspect if result != 3509

puts("part 2 - #{process(input, true)}")