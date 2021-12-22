def take_turn_with_cache(game, cache)
  if cache.include?(game)
    return cache[game]
  end
  result = take_turn(game, cache)
  cache[game] = result
  result
end

def take_turn(game, cache)
  if game[2] >= 21
    return [1, 0]
  elsif game[3] >= 21
    return [0, 1]
  end

  total_p0_wins = 0
  total_p1_wins = 0

  (1..3).each do |roll1|
    (1..3).each do |roll2|
      (1..3).each do |roll3|
        total_move = roll1 + roll2 + roll3

        new_pawn_location = game[4] == 0 ? move_pawn(game[0], total_move) : move_pawn(game[1], total_move)
        new_score = game[4] == 0 ? game[2] + new_pawn_location : game[3] + new_pawn_location
        new_game = [
          game[4] == 0 ? new_pawn_location : game[0],
          game[4] == 1 ? new_pawn_location : game[1],
          game[4] == 0 ? new_score : game[2],
          game[4] == 1 ? new_score : game[3],
          (game[4] + 1) % 2,
        ]
        p0_wins, p1_wins = take_turn_with_cache(new_game, cache)
        total_p0_wins += p0_wins
        total_p1_wins += p1_wins
      end
    end
  end

  [total_p0_wins, total_p1_wins]
end

def move_pawn(current_location, roll)
  ((current_location - 1 + roll) % 10) + 1
end

def play(game)
  take_turn_with_cache(game, {})
end

def part2(game)
  start = Time.now
  wins = play(game)
  puts("Finished in #{Time.now - start} seconds")
  wins
end

# part 2
game = [
  4, # 1 - pawn 0 location
  8, # 2 - pawn 1 location
  0, # 3 - pawn 0 score
  0, # 4 - pawn 1 score
  0, # 5 - whose turn,
]
wins = part2(game)
raise wins.inspect unless wins == [444356092776315, 341960390180808]

game = [
  4, # 1 - pawn 0 location
  9, # 2 - pawn 1 location
  0, # 3 - pawn 0 score
  0, # 4 - pawn 1 score
  0, # 5 - whose turn,
]
wins = part2(game)
puts("wins: #{wins.max}")
