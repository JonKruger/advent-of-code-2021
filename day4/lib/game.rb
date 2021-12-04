class Game
  def initialize(hopper)
    @boards = []
    @winners = []
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

    @boards.each do |board|
      @winners << board if board.bingo? && !@winners.include?(board)
    end
    nil
  end

  def draw_until_winner
    while (winners.none? && !@hopper.empty?) do
      draw
    end
  end

  def draw_until_all_win
    while (winners.size < boards.size && !@hopper.empty?) do
      draw
    end
    raise "hopper ran out before all boards won" unless winners.size == boards.size
  end

  def winners
    @winners.dup.freeze
  end

  def final_score_of_first_winner
    return winners.first.sum_of_unmarked_numbers * @last_draw if winners.any?
  end

  def final_score_of_last_winner
    return winners.last.sum_of_unmarked_numbers * @last_draw if winners.any?
  end
end

