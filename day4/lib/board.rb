class Board
  def initialize(data)
    @data = data
  end

  def [](row, col)
    @data[row][col]
  end
end
