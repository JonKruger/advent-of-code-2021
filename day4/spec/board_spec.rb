require "spec_helper"

describe Board do
  let(:board_input) do
    <<-BOARD
24 75 59 41 17
58 74 64 92 39
68  8 78 85 72
18  3 22  4 34
11 76  6 28 50
    BOARD
  end
  let(:board) { BoardParser.new.parse(board_input)[0] }

  context "#exists?" do
    it "returns whether a number is on the board" do
      expect(board.exists?(8)).to be true
      expect(board.exists?(-8)).to be false
    end
  end

  context "marking a number" do
    it "should mark a number that exists on the board" do
      board.mark(78)
      expect(board.marked?(78)).to be true
      expect(board.marked?(24)).to be false
    end

    it "should not mark a number that doesn't exist on the board" do
      board.mark(-1)
      expect(board.marked?(24)).to be false
    end
  end

  context "vertical bingo" do
    it "should recognize vertical bingo" do
      [24, 75, 59, 41].each { |number| board.mark(number )}
      expect(board.bingo?).to be false

      board.mark(17)
      expect(board.bingo?).to be true
    end
  end

  context "horizontal bingo" do
    it "should recognize horizontal bingo" do
      [24, 58, 68, 11].each { |number| board.mark(number )}
      expect(board.bingo?).to be false

      board.mark(18)
      expect(board.bingo?).to be true
    end
  end

  context "diagonal bingo is not a thing" do
    it "should not recognize diagonal bingo" do
      [24, 74, 78, 4, 50].each { |number| board.mark(number )}
      expect(board.bingo?).to be false
    end
  end

  context "#sum_of_unmarked_numbers" do
    it "should sum unmarked numbers" do
      marked_numbers = %w[24 75 59 41 17 58 74 64 92 39 68  8 78 85 72 18  3 22  4 34].map(&:to_i)
      unmarked_numbers = %w[11 76  6 28 50].map(&:to_i)
      marked_numbers.each { |number| board.mark(number) }
      expect(board.sum_of_unmarked_numbers).to eq(unmarked_numbers.sum)
    end
  end
end