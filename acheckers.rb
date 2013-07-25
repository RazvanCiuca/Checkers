require "gosu"

class Board
  attr_accessor :board
  def initialize
    @board = Array.new(8) {Array.new(8,nil)}
  end

end

class Piece
  attr_accessor :pos, :image
  def initialize(pos, color, window)
    @pos = pos
    @image = Gosu::Image.new(window, "#{Dir.pwd}/#{color}_checker.png", false)
    @color = color

  end

  def possible_moves
    dir = (@color == :black ? 1 : -1)
    possible_moves = []



    return possible_moves #array of possible chains
  end

  def on_board?(destination)


  end

  def coords
    [pos[1]*100 + 10, pos[0]*100 + 10]
  end
end

class Board
  attr_reader :pieces
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
  end


  def update

  end

  def draw
    @background.draw(0,0,0)
    @cursor.draw(self.mouse_x - 20, self.mouse_y - 20, 2)
    self.draw_pieces

  end

  def button_down(id)
    if id == Gosu::MsLeft
      x = (self.mouse_x / 100).to_i
      y = (self.mouse_y / 100).to_i
      self.choose_action(y, x)
    else


    end
  end

  def choose_action(x, y)
    if @mouse_loaded
      #display possible moves
      self.unload_piece(x, y)
      @mouse_loaded = !@mouse_loaded


    else
      if self.load_piece(x, y)
        @load.possible_moves
        @mouse_loaded = !@mouse_loaded
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
    @cursor = @original_cursor
  end

  def load_images
    assets = ["cursor1.png","chessboard.png"]
    paths = {}
    assets.each do |asset|
      paths[asset] = File.join(Dir.pwd, asset)
    end

    @background = Gosu::Image.new(self, paths["chessboard.png"], false)
    @original_cursor = Gosu::Image.new(self, paths["cursor1.png"], true)

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
