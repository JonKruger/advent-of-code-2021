class Node
    attr_reader :value, :neighbors

    def initialize(value)
        raise unless !value.nil? && value.is_a?(Integer)
        @value = value
        @neighbors = []
    end

    def low_point?
        neighbors.all? { |n| n.value > value }
    end

    def basin
        ([self] + neighbors.select { |node| node.value > value && node.value != 9 }.map(&:basin))
          .flatten
          .uniq
    end

    def risk_level
        value + 1
    end
end

def build_nodes(input)
    rows = input.split("\n").compact.map { |row| row.chars.compact.map { |value| Node.new(value.to_i) } }
    num_rows = rows.size
    num_cols = input.split("\n").compact[0].length

    low_points = []
    (0...num_rows).each do |row|
        (0...num_cols).each do |col|
            this_node = rows[row][col]
            this_node.neighbors << rows[row][col-1] if col > 0
            this_node.neighbors << rows[row][col+1] if col < num_cols - 1
            this_node.neighbors << rows[row-1][col] if row > 0
            this_node.neighbors << rows[row+1][col] if row < num_rows - 1
        end
    end
    all_nodes = rows.flatten

    raise if all_nodes.any? { |node| node.value.nil? }
    raise if all_nodes.any? { |node| node.neighbors.length < 2 }

    all_nodes
end

def part1(input)
    nodes = build_nodes(input)
    nodes.select { |node| node.low_point? }.map { |node| node.risk_level }.sum
end

def part2(input)
    nodes = build_nodes(input)
    low_points = nodes.select { |node| node.low_point? }
    low_points.map(&:basin).map(&:size).sort.reverse[0..2].inject(:*)
end

test_input = <<-INPUT
2199943210
3987894921
9856789892
8767896789
9899965678
INPUT
result = part1(test_input)
raise result.inspect if result != 15

result = part2(test_input)
raise result.inspect if result != 1134

input = File.read("input.txt")
puts "part1 - #{part1(input)}"
puts "part2 - #{part2(input)}"
