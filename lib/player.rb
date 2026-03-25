# This represents a single player of chess
class Player
  attr_reader :color, :name

  def initialize(color)
    @color = color
    @name = take_player_name
  end

  def take_player_name
    color_name = @color == "w" ? "white" : "black"
    print "Player #{color_name}, what is your name? "
    name = gets.chomp
    print "\n\n"

    name
  end
end
