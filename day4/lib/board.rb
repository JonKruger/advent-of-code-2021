class Board
  def initialize(data)
    @data = data
    @marked_numbers = []
  end

  def [](row, col)
    @data[row][col]
  end

  def mark(number)
    @marked_numbers << number if exists?(number)
  end

  def marked?(number)
    @marked_numbers.include?(number)
  end

  def bingo?
    vertical_bingo? || horizontal_bingo?
  end

  def exists?(number)
    @data.any? { |row| row.any? { |col| col == number} }
  end

  def sum_of_unmarked_numbers
    @data.flatten.select { |number| !marked?(number) }.sum
  end

  private

  def vertical_bingo?
    (0..5).each do |col|
      return true if @data.all? { |row| marked?(row[col]) }
    end
    false
  end

  def horizontal_bingo?
    @data.any? { |row| row.all? { |col| marked?(col) }}
  end
end
