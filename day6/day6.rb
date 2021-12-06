def process_days(days, fish)
  groups = fish.tally
  days.times do
    groups = process_day(groups)
  end
  groups.values.sum
end

def process_day(groups)
  new_groups = {}

  # initialize empty groups that we'll add to.
  # remember that 7's can become 6's and 0's can become 6's!
  (0..8).each { |value| new_groups[value] = 0 }
  groups.each do |value, amount|
    if value == 0
      new_groups[6] += amount
      new_groups[8] += amount
    else
      new_groups[value - 1] += amount
    end
  end
  new_groups
end

result = process_days(3, [3,4,3,1,2])
raise result.inspect if result != [0,1,0,5,6,7,8].size

result = process_days(18, [3,4,3,1,2])
raise result.inspect if result != [6,0,6,4,5,6,0,1,1,2,6,0,1,1,1,2,2,3,3,4,6,7,8,8,8,8].size

result = process_days(256, [3,4,3,1,2])
raise result.inspect if result != 26984457539

# part 1
fish = [3,1,4,2,1,1,1,1,1,1,1,4,1,4,1,2,1,1,2,1,3,4,5,1,1,4,1,3,3,1,1,1,1,3,3,1,3,3,1,5,5,1,1,3,1,1,2,1,1,1,3,1,4,3,2,1,4,3,3,1,1,1,1,5,1,4,1,1,1,4,1,4,4,1,5,1,1,4,5,1,1,2,1,1,1,4,1,2,1,1,1,1,1,1,5,1,3,1,1,4,4,1,1,5,1,2,1,1,1,1,5,1,3,1,1,1,2,2,1,4,1,3,1,4,1,2,1,1,1,1,1,3,2,5,4,4,1,3,2,1,4,1,3,1,1,1,2,1,1,5,1,2,1,1,1,2,1,4,3,1,1,1,4,1,1,1,1,1,2,2,1,1,5,1,1,3,1,2,5,5,1,4,1,1,1,1,1,2,1,1,1,1,4,5,1,1,1,1,1,1,1,1,1,3,4,4,1,1,4,1,3,4,1,5,4,2,5,1,2,1,1,1,1,1,1,4,3,2,1,1,3,2,5,2,5,5,1,3,1,2,1,1,1,1,1,1,1,1,1,3,1,1,1,3,1,4,1,4,2,1,3,4,1,1,1,2,3,1,1,1,4,1,2,5,1,2,1,5,1,1,2,1,2,1,1,1,1,4,3,4,1,5,5,4,1,1,5,2,1,3]
puts "part 1 - #{process_days(80, fish)}"
puts "part 2 - #{process_days(256, fish)}"