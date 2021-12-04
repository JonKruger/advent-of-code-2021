class BoardParser
  def parse(input)
    split_board_inputs(input).map { |input| parse_single_board(input) }
  end

  private

  def parse_single_board(input_array)
    rows = input_array.map { |row| row.split(" ").compact.map(&:to_i) }
    Board.new(rows)
  end

  def split_board_inputs(input)
    board_inputs = []
    single_board_input = []
    raw_rows = input.split("\n")
    raw_rows.each do |row|
      if row.strip.length > 0
        single_board_input << row
      end

      if single_board_input.length == 5
        board_inputs << single_board_input
        single_board_input = []
      end
    end

    board_inputs
  end
end