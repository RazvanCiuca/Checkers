def sliding_moves(board)
  x, y = 1,2
  sliding_moves = []
  moves = [[x + 1, y + 1], [x + 1, y - 1]]
  moves.each do |move|
    if on_board?(move) && board[move[0]][move[1]].nil?
      sliding_moves << move
    end
  end
  sliding_moves
end
def on_board?(destination)
  x, y = destination
  return false if x < 0 || x > 7 || y < 0 || y > 7
  true
end
board = Array.new(8) { Array.new(8) }

p sliding_moves(board)