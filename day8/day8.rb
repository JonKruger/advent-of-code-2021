def parse_line(input_line)
  digits, input = input_line.split("|")
  digit_strings = digits.split(" ").map(&:strip).map { |s| s.chars.sort.join }
  input_strings = input.split(" ").map(&:strip).map { |s| s.chars.sort.join }
  [digit_strings, input_strings]
end

def part1(input_line)
  _, input_strings = parse_line(input_line)
  input_strings.select { |s| [2,3,4,7].include?(s.size) }.size
end

def in_common(x, y)
  x.chars.intersection(y.chars)
end

def part2(input_line)
  digit_strings, input_strings = parse_line(input_line)

  # these are obvious
  one = digit_strings.select { |s| s.size == 2 }.first
  seven = digit_strings.select { |s| s.size == 3 }.first
  four = digit_strings.select { |s| s.size == 4 }.first
  eight = digit_strings.select { |s| s.size == 7 }.first

  # figure out the rest by comparing common segments with known numbers
  zero = digit_strings.select do |s|
    s.size == 6 && in_common(s, four).size == 3 && in_common(s, seven).size == 3
  end.first

  two = digit_strings.select do |s|
    s.size == 5 && in_common(s, four).size == 2
  end.first

  five = digit_strings.select do |s|
    s.size == 5 && s != two && in_common(s, seven).size == 2
  end.first

  three = digit_strings.select do |s|
    s.size == 5 && ![two, five].include?(s)
  end.first

  nine = digit_strings.select do |s|
    s.size == 6 && in_common(s, one).size == 2 && in_common(s, five).size == 5
  end.first

  six = digit_strings.select do |s|
    s.size == 6 && ![zero, nine].include?(s)
  end.first

  decoded_digits = [zero, one, two, three, four, five, six, seven, eight, nine]
  input_strings.map { |s| decoded_digits.index(s).to_s }.join.to_i
end

result = part1("bacd gcaeb agd begdf bgdea gdbaec fcageb cegdfa afebdgc ad | egdab edgcfa ad bgcafed")
raise result.inspect unless result == 2

result = part1("fdabc ef cfaed daebgc fgebda fde dceag gfce cbgfdea eacfgd | adceg edbcagf edf fe")
raise result.inspect unless result == 3

result = part1("dagebf bdc bc afecd daceb cgbe dabceg edbag dfcagb cefgbad | dbc dabge abdgce cegb")
raise result.inspect unless result == 2

# technically I should've written more tests than this that cover all input numbers
# but I got lucky and got it right anyway
result = part2("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")
raise result.inspect unless result == 5353

raw_lines = File.read("input.txt")
lines = raw_lines.split("\n").compact
puts "part1", lines.map { |line| part1(line) }.sum
puts "part2", lines.map { |line| part2(line) }.sum
