require "gosu"

class GameWindow < Gosu::Window
  attr_accessor :board
  def initialize
    super 800, 800, false, 50
    self.caption = "Checkers!"
    p "started"
    @board = Array.new(8) {Array.new(8,nil)}
    @background = Gosu::Image.new(self, "/Users/appacademy/Desktop/snake/Snake/chessboard.png", false)
    @cursor = Gosu::Image.new(self,"/Users/appacademy/Desktop/w2d3/TicTacToe/cursor1.png", true)
  end


  def update
  end

  def draw
    @background.draw(0,0,0)
    @cursor.draw(self.mouse_x, self.mouse_y,2)
  end

  def button_down(id)
    if id == Gosu::MsLeft
      x = self.mouse_x / 100
      y = self.mouse_y / 100
      @board[x][y] = 1


    end
  end
end

game = GameWindow.new
game.show
