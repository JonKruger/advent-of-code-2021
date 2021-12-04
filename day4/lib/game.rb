class Game
  def initialize(hopper)
    @boards = []
    @hopper = hopper
    @last_draw = nil
  end

  def add_boards(boards)
    boards.each { |board| add_board(board) }
  end

  def add_board(board)
    @boards << board
  end

  def boards
    @boards.dup.freeze
  end

  def draw
    number = @hopper.draw
    @boards.each { |board| board.mark(number) }
    @last_draw = number
    nil
  end

  def draw_until_winner
    while (!winner && !@hopper.empty?) do
      draw
    end
  end

  def winner
    @boards.select { |board| board.bingo? }.first
  end

  def final_score
    return winner.sum_of_unmarked_numbers * @last_draw if winner
  end
end

