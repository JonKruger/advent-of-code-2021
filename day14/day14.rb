def parse_input(input)
  input.split("\n").compact.map { |line| line.split(" -> ") }.to_h
end

def step(input, starting_point, steps)
  instructions = parse_input(input)
  transformations = instructions.map do |pair, new_value|
    [pair, [pair[0] + new_value, new_value + pair[1]]]
  end.to_h

  # split the string into chunks and tally the chunks
  chunks = []
  (0...(starting_point.size - 1)).each do |i|
    chunks << starting_point[i..(i+1)]
  end
  chunks = chunks.tally

  # for each chunk, calculate how many new chunks will be birthed from it
  steps.times do |step|
    new_chunks = chunks.map { |chunk, _| [chunk, 0] }.to_h
    chunks.each do |chunk, count|
      transformations[chunk].each do |new_value|
        new_chunks[new_value] ||= 0
        new_chunks[new_value] += count
      end
    end
    chunks = new_chunks
  end

  # determine frequency of each character
  char_tally = {}
  chunks.each do |chunk, count|
    char_tally[chunk[0]] ||= 0
    char_tally[chunk[0]] += count
  end

  # don't forget the last char of the string, which will never be the first
  # character of a chunk, and will never change
  char_tally[starting_point.chars.last] ||= 0
  char_tally[starting_point.chars.last] += 1

  sorted_char_tally = char_tally.sort_by { |_,v| v }
  sorted_char_tally.last[1] - sorted_char_tally.first[1]
end

test_input = <<-INPUT
CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
INPUT
result = step(test_input, "NNCB", 1)
raise result.inspect if result != 1 # "NCNBCHB"

result = step(test_input, "NNCB", 2)
raise result.inspect if result != 5 # "NBCCNBBBCBHCB"

result = step(test_input, "NNCB", 10)
raise result.inspect if result != 1588

input = File.read("input.txt")
puts("part 1 - #{step(input, "ONSVVHNCFVBHKVPCHCPV", 10)}")
puts("part 2 - #{step(input, "ONSVVHNCFVBHKVPCHCPV", 40)}")

