# This class records relevant information about a piece on a chess
# board, such as its type, color, and information pertaining to special rules
# (such as castling)
class Piece
  attr_accessor :position
  attr_reader :color, :type

  def initialize(color, type, position)
    @color = color
    construct_piece(type)
    @position = position
  end

  def construct_piece(type)
    @type = type

    case type
    when "p" then construct_pawn
    when "R" then construct_rook
    when "K" then construct_king
    end
  end

  private

  def construct_pawn
    @move_by_two = true
    @can_en_passant = false

    # creates an attribute accessor that is unique to the
    # current instance of this class
    singleton_class.class_eval { attr_accessor "move_by_two" }
    singleton_class.class_eval { attr_accessor "can_en_passant" }
  end

  def construct_rook
    @can_castle = true

    singleton_class.class_eval { attr_accessor "can_castle" }
  end

  def construct_king
    @can_castle = true

    singleton_class.class_eval { attr_accessor "can_castle" }
  end
end
