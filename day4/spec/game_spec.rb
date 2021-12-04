require "spec_helper"

describe Game do
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
  let(:boards) { BoardParser.new.parse(multiple_board_input) }
  let(:numbers_to_draw) { [24, 21] }
  let(:hopper) { Hopper.new(numbers_to_draw)}
  subject do
    game = Game.new(hopper)
    game.add_boards(boards)
    game
  end

  context "boards" do
    it "can add a board to the game" do
      subject.add_board(boards[0])
      expect(subject.boards).to include(boards[0])
    end

    it "can add multiple boards to the game" do
      subject.add_boards(boards)
      expect(subject.boards).to include(boards[0])
      expect(subject.boards).to include(boards[1])
    end
  end

  context "drawing" do
    it "should mark the number on the boards that have it" do
      subject.draw # 24
      expect(boards[0].marked?(24)).to be true
      expect(boards[1].marked?(24)).to be false
    end
  end

  context "winner" do
    let(:numbers_to_draw) { [24, 75, 59, 41, 17] }

    it "should return nil if no winner" do
      expect(subject.winner).to be_nil
    end

    it "should identify a winning board" do
      5.times { subject.draw }
      expect(subject.winner).to eq(boards[0])
    end
  end

  context "draw_until_winner" do
    let(:numbers_to_draw) { [24, 75, 59, 41, 17] }
    it "should draw until a winner is found" do
      subject.draw_until_winner
      expect(subject.winner).to eq(boards[0])
    end
  end

  context "final_score" do
    let(:numbers_to_draw) { [24, 75, 59, 41, 17] }
    let(:unmarked_numbers) { %w[58 74 64 92 39 68  8 78 85 72 18  3 22  4 34 11 76  6 28 50].map(&:to_i) }
    it "should equal sum of winning board * last number" do
      5.times { subject.draw }
      expect(subject.final_score).to eq(unmarked_numbers.sum * 17)
    end

    it "should return nil if no winner yet" do
      expect(subject.final_score).to be_nil
    end
  end
end
