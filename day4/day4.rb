project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/lib/**/*.rb', &method(:require))

file = File.open("lib/hopper_input.txt")
hopper_input = file.read
hopper = HopperParser.new.parse(hopper_input)

file = File.open("lib/boards_input.txt")
board_input = file.read
boards = BoardParser.new.parse(board_input)

game = Game.new(hopper)
game.add_boards(boards)
game.draw_until_winner
puts game.final_score