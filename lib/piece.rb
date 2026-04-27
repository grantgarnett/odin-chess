require_relative "basic_serializable"

# This class records relevant information about a piece on a chess
# board, such as its type, color, and information pertaining
# to special rules (such as castling)
class Piece
  include BasicSerializable

  attr_accessor :position, :color, :move_by_two, :can_en_passant, :can_castle,
                :type

  def initialize(color, type, position)
    @color = color
    construct_piece(type)
    @position = position
  end

  def construct_piece(type)
    @type = type

    construct_pawn if type == "p"
    construct_rook_or_king if %w[R K].include?(type)
  end

  private

  def construct_pawn
    @move_by_two = true
    @can_en_passant = false
  end

  def construct_rook_or_king
    @can_castle = true
  end
end
