require_relative "basic_serializable"

# This represents a single player of chess
class Player
  include BasicSerializable

  attr_reader :color, :name

  def initialize(color)
    @color = color
  end
end
