require "gosu"

class Piece
  attr_accessor :pos, :image, :color
  attr_reader :king
  def initialize(pos, color, window)
    @pos = pos
    @image = Gosu::Image.new(window, "#{Dir.pwd}/#{color}_checker.png", false)
    @color = color
    @dir = (@color == :black ? 1 : -1)
    @king = false
    @window = window
  end

  def king=(arg)
    @king = arg
    @image = Gosu::Image.new(@window, "#{Dir.pwd}/#{color}_king.png", false)
  end

  def sliding_moves(board)
    x, y = @pos
    sliding_moves = []
    moves = [[x + @dir, y + 1], [x + @dir, y - 1]]
    if @king
      moves += [[x - @dir, y + 1], [x - @dir, y - 1]]
    end
    moves.each do |move|
      if on_board?(move) && board[move[0]][move[1]].nil?
        sliding_moves << move
      end
    end
    sliding_moves
  end

  def jump_moves(board)
    x, y = @pos
    jump_moves = []
    to_be_eaten = []
    moves = [[x + 2*@dir, y +2], [x + 2*@dir, y - 2]]
    obstacles = [[x + @dir, y + 1], [x + @dir, y - 1 ]]
    if @king
      moves += [[x - 2*@dir, y + 2], [x - 2*@dir, y - 2]]
      obstacles += [[x - @dir, y + 1], [x - @dir, y - 1]]
    end
    moves.each_with_index do |move, ind|
      i, j = move
      if on_board?(move) && board[i][j].nil?
        if board[obstacles[ind][0]][obstacles[ind][1]] != nil
          if board[obstacles[ind][0]][obstacles[ind][1]].color != @color
            jump_moves << move
            to_be_eaten << obstacles[ind]
          end
        end
      end
    end
    [jump_moves, to_be_eaten]
  end

  def possible_moves(board)
    possible_moves = []
    sliding_moves(board).each do |move|
      possible_moves << [move,nil]
    end

    possible_moves += jump_moves(board).transpose
    possible_moves
  end

  def on_board?(destination)
    x, y = destination
    return false if x < 0 || x > 7 || y < 0 || y > 7
    true
  end

  def coords
    [pos[1]*100 + 10, pos[0]*100 + 10]
  end
end

class Board
  attr_reader :pieces, :board
  def initialize(window)
    @board = Array.new(8) {Array.new(8)}
    @pieces = []
    3.times do |i|
      4.times do |j|
        x, y = i, (2 * j + (i + 1) % 2)
        @board[x][y] = Piece.new([x,y], :black, window)
        @pieces << [x, y]
      end
    end

    3.times do |i|
      4.times do |j|
        x, y = 5 + i, (2 * j + i % 2)
        @board[x][y] = Piece.new([x,y], :red, window)
        @pieces << [x, y]
      end
    end
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def []=(pos,piece)
    @board[pos[0]][pos[1]] = piece
  end

end

class GameWindow < Gosu::Window
  attr_accessor :board
  def initialize
    super 800, 800, false, 50
    self.caption = "Checkers!"
    self.load_images
    @board = Board.new(self)
    @pieces = @board.pieces
    @mouse_loaded = false
    @cursor = @original_cursor
    @turn = 0
  end


  def update

  end

  def draw
    @background.draw(0,0,0)
    @cursor.draw(self.mouse_x - 20, self.mouse_y - 20, 3)
    self.draw_pieces
    self.draw_possible_moves
  end

  def button_down(id)
    if id == Gosu::MsLeft
      x = (self.mouse_x / 100).to_i
      y = (self.mouse_y / 100).to_i
      self.choose_action(y, x)
    end
  end

  def draw_possible_moves
    unless @load.nil?
      @load.possible_moves(@board.board).each do |move|
        x = move[0][1]*100 + 10
        y = move[0][0]*100 + 10
        @highlight.draw(x, y, 2)
      end
    end
  end

  def choose_action(x, y)
    if @mouse_loaded
      @keep_going = false
      if @load.pos == [x,y] #allows to drop piece in starting position
        self.unload_piece(x, y)
        @keep_going = true
      else
        destinations = @load.possible_moves(@board.board).transpose[0]
        could_be_eaten = @load.possible_moves(@board.board).transpose[1]
        which_move = destinations.index([x,y]) if destinations
        if which_move
          self.unload_piece(x, y)
          about_to_die = could_be_eaten[which_move]
          if about_to_die #if it jumped and ate something
            @pieces.delete(about_to_die)
            @board[about_to_die] = nil
            @keep_going = true unless @board[[x,y]].possible_moves(@board.board).empty?
          end
        end
      end
      @turn = 1 - @turn unless @keep_going
      @mouse_loaded = !@mouse_loaded
    else
      if @board[[x,y]].color == (@turn == 0 ? :red : :black)
        if self.load_piece(x, y)
          @mouse_loaded = !@mouse_loaded
        end
      end
    end

  end

  def load_piece(x, y)
    unless @board[[x, y]].nil?
      @load = @board[[x, y]]
      @cursor = @load.image
      @pieces.delete([x, y])
      @board[[x, y]] = nil
      return true
    end
    false
  end

  def unload_piece(x, y)
    @board[[x,y]] = @load #puts the piece down
    @pieces << [x, y] #adds it to pieces again
    @board[[x,y]].pos = [x, y]
    throne_row = (@load.color == :red ? 0 : 7)
    if x == throne_row
      @board[[x,y]].king = true
    end
    @cursor = @original_cursor
    @load = nil
  end

  def load_images
    assets = ["cursor1.png","chessboard.png","highlight.png"]
    paths = {}
    assets.each do |asset|
      paths[asset] = File.join(Dir.pwd, asset)
    end

    @background = Gosu::Image.new(self, paths["chessboard.png"], false)
    @original_cursor = Gosu::Image.new(self, paths["cursor1.png"], true)
    @highlight = Gosu::Image.new(self, paths["highlight.png"], false)
  end

  def draw_pieces
    @pieces.each do |piece|
      x, y = @board[[piece[0],piece[1]]].coords
      @board[[piece[0],piece[1]]].image.draw(x, y, 1)
    end
  end

end


game = GameWindow.new
game.show
