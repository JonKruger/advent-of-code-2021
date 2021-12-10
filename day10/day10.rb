def part1(input)
  input.split("\n").compact.map { |line| score_line(line) }.compact.sum
end

def part2(input)
  scores = input.split("\n").compact.map { |line| score_line_completion(line) }.compact.sort
  scores[(scores.length / 2).to_i]
end

def score_line(input)
  stack = []
  openers = ["{","[","<","("]
  closers = ["}","]",">",")"]

  input.chars.each do |c|
    if openers.include?(c)
      stack << c
    elsif closers.include?(c)
      top_of_stack = stack.pop
      return 3 if c == ")" && top_of_stack != "("
      return 57 if c == "]" && top_of_stack != "["
      return 1197 if c == "}" && top_of_stack != "{"
      return 25137 if c == ">" && top_of_stack != "<"
    end
  end

  return nil
end

def score_line_completion(input)
  stack = []
  openers = ["{","[","<","("]
  closers = ["}","]",">",")"]

  input.chars.each do |c|
    if openers.include?(c)
      stack << c
    elsif closers.include?(c)
      top_of_stack = stack.pop
      return nil if c == ")" && top_of_stack != "("
      return nil if c == "]" && top_of_stack != "["
      return nil if c == "}" && top_of_stack != "{"
      return nil if c == ">" && top_of_stack != "<"
    end
  end

  return nil if stack.empty?

  completion = stack.map do |c|
    case c
    when "(" then ")"
    when "[" then "]"
    when "<" then ">"
    when "{" then "}"
    end
  end.reverse

  completion.inject(0) do |score, c|
    score *= 5
    score += 1 if c == ")"
    score += 2 if c == "]"
    score += 3 if c == "}"
    score += 4 if c == ">"
    score
  end
end

# incorrect )
result = score_line("[[<[([]))<([[{}[[()]]]")
raise result.inspect if result != 3

# incorrect ]
result = score_line("[{[{({}]{}}([{[{{{}}([]")
raise result.inspect if result != 57

# incorrect }
result = score_line("{([(<{}[<>[]}>{[]{[(<()>")
raise result.inspect if result != 1197

# incorrect >
result = score_line("<{([([[(<>()){}]>(<<{{")
raise result.inspect if result != 25137

# incomplete
result = score_line("<{()")
raise result.inspect if result != nil

# valid
result = score_line("<>")
raise result.inspect if result != nil

input = File.read("input.txt")
puts(part1(input))

result = score_line_completion("[({(<(())[]>[[{[]{<()<>>")
raise result.inspect if result != 288957

result = score_line_completion("[(()[<>])]({[<{<<[]>>(")
raise result.inspect if result != 5566

puts(part2(input))