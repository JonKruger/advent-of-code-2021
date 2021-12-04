require 'rspec'

class Board
  def initialize(data)
    @data = data
  end

  def [](row, col)
    @data[row][col]
  end
end

class BoardParser
  def parse(input)
    split_board_inputs(input).map { |input| parse_single_board(input) }
  end

  def parse_single_board(input_array)
    rows = input_array.map { |row| row.split(" ").compact.map(&:to_i) }
    Board.new(rows)
  end

  private

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

describe BoardParser do
  let(:board_input) do
    <<-BOARD
24 75 59 41 17
58 74 64 92 39
68  8 78 85 72
18  3 22  4 34
11 76  6 28 50
    BOARD
  end

  let(:multiple_board_input) do
    <<-BOARD
24 75 59 41 17
58 74 64 92 39
68  8 78 85 72
18  3 22  4 34
11 76  6 28 50

21 31 36 13 87
80 91 63 62 77
46 93 40 16 25
47 66 30 54 74
56 59 86 72 37
    BOARD
  end

  it "should parse a single board" do
    board = subject.parse(board_input)[0]
    expect(board[0,0]).to eq(24)
    expect(board[4,4]).to eq(50)
  end

  it "should parse multiple boards" do
    boards = subject.parse(multiple_board_input)
    expect(boards[0][0,0]).to eq(24)
    expect(boards[1][0,0]).to eq(21)
  end
end

