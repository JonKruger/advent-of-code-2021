require 'spec_helper'

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

