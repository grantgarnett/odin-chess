require_relative "in_out"
require_relative "board"
require_relative "player"

# description to be added
class Game
  include InOut

  def initialize
    @chess_board = Board.new
    @player_white = Player.new("w")
    @player_black = Player.new("b")
    play_game
  end

  def play_game
  end
end
