def process(input)
    rows = input.split("\n").compact.map { |row| row.chars.compact }
    num_rows = rows.size
    num_cols = input.split("\n").compact[0].length

    low_points = []
    (0...num_rows).each do |row|
        (0...num_cols).each do |col|
            this_value = rows[row][col].to_i
            if (col == 0 || this_value < rows[row][col-1].to_i) \
                && (col == num_cols - 1 || this_value < rows[row][col+1].to_i) \
                && (row == 0 || this_value < rows[row-1][col].to_i) \
                && (row == num_rows - 1 || this_value < rows[row+1][col].to_i)
                low_points << this_value
            end
        end
    end
    low_points.map { |p| p.to_i + 1 }.sum
end

test_input = <<-INPUT
2199943210
3987894921
9856789892
8767896789
9899965678
INPUT
result = process(test_input)
raise result.inspect if result != 15

input = File.read("input.txt")
puts "part1 - #{process(input)}"