def take_turn(game)
  new_pawn_location = game[5] == 0 ? move_pawn(game[1], game[0]) : move_pawn(game[2], game[0])
  new_score = game[5] == 0 ? game[3] + new_pawn_location : game[4] + new_pawn_location
  [
    die_plus_3(game[0]),
    game[5] == 0 ? move_pawn(game[1], game[0]) : game[1],
    game[5] == 1 ? move_pawn(game[2], game[0]) : game[2],
    game[5] == 0 ? new_score : game[3],
    game[5] == 1 ? new_score : game[4],
    (game[5] + 1) % 2,
    game[6] + 3,
    new_score >= 1000 ? game[5] : nil
  ]
end

def die_plus_3(next_roll_value)
  ((next_roll_value - 1 + 3) % 100) + 1
end

def next_3_rolls(next_roll_value)
  if next_roll_value == 99
    99 + 100 + 1
  elsif next_roll_value == 100
    100 + 1 + 2
  else
    (next_roll_value * 3) + 3
  end
end

def move_pawn(current_location, next_roll_value)
  ((current_location - 1 + next_3_rolls(next_roll_value)) % 10) + 1
end

def play(game)
  while (game[7].nil?) do
    game = take_turn(game)
    puts(game.inspect)
  end
  game
end

def part1(game)
  start = Time.now
  game = play(game)
  puts("Finished in #{Time.now - start} seconds")
  [game[3], game[4]].min * game[6]
end


game = [
  1, # next_roll_value
  4, # pawn 0 location
  8, # pawn 1 location
  0, # pawn 0 score
  0, # pawn 1 score
  0, # whose turn,
  0, # die_rolls
  nil # winner
]
raise unless part1(game) == 739785

# part 1
game = [
  1, # next_roll_value
  4, # pawn 0 location
  9, # pawn 1 location
  0, # pawn 0 score
  0, # pawn 1 score
  0, # whose turn,
  0, # die_rolls
  nil # winner
]
game = play(game)
puts("part 1 - #{part1(game)}")