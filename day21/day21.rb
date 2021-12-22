class Die
  attr_reader :roll_count

  def initialize(max_value)
    @next_roll_value = 1
    @roll_count = 0
    @max_value = max_value
  end

  def roll
    value = @next_roll_value
    @next_roll_value = @next_roll_value == @max_value ? 1 : @next_roll_value + 1
    @roll_count += 1
    value
  end
end

class Pawn
  attr_reader :score

  def initialize(starting_location, die)
    @location = starting_location
    @die = die
    @score = 0
  end

  def take_turn
    total_roll = 3.times.collect { @die.roll }.sum
    move(total_roll)
    @score += @location
  end

  def move(number)
    @location = (((@location - 1) + number) % 10) + 1
  end

  def wins?
    @score >= 1000
  end
end

class Universe
  attr_reader :pawns, :die

  def initialize(pawn_starting_locations:, current_pawn_index:, winning_score:, die_max_value:, on_completion: )
    @winning_score = winning_score
    @die = Die.new(die_max_value)
    @pawns = pawn_starting_locations.map { |location| Pawn.new(location, die) }
    @current_pawn_index = current_pawn_index
    @on_completion = on_completion
  end

  def play
    while (true) do
      current_pawn = @pawns[@current_pawn_index]
      current_pawn.take_turn
      if current_pawn.wins?
        @on_completion.call(@current_pawn_index)
        break
      end
      @current_pawn_index = (@current_pawn_index == @pawns.size - 1 ? 0 : @current_pawn_index + 1)
    end
  end
end

# test rolling
die = Die.new(10)
raise unless die.roll == 1
raise unless die.roll == 2
raise unless die.roll == 3
7.times { die.roll }
raise unless die.roll == 1
raise unless die.roll_count == 11

# test taking turn
die = Die.new(10)
pawn = Pawn.new(5, die)
pawn.take_turn # rolls 1,2,3
raise pawn.score.inspect unless pawn.score == 1

# part 1 example
def part1(pawn_starting_locations)
  start = Time.now
  wins = {0 => 0, 1 => 0}
  on_completion = lambda { |winning_pawn_index| wins[winning_pawn_index] += 1 }
  universe = Universe.new(
    pawn_starting_locations: pawn_starting_locations,
    current_pawn_index: 0,
    winning_score: 100,
    die_max_value: 10,
    on_completion: on_completion
  )
  universe.play

  losing_pawn = universe.pawns.select { |p| !p.wins? }.first
  puts("Finished in #{Time.now - start} seconds")
  losing_pawn.score * universe.die.roll_count
end

raise unless part1([4, 8]) == 739785

puts("part 1 - #{part1([4,9])}")