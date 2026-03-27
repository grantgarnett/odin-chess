require_relative "validate_moves"

# this module provides methods that allow
# something with access to a chess board state
# to determine if a team's king is in check
#
# this module needs access to methods that
# calculate taking moves for a piece and
# access to methods that calculate defending
# moves for a piece. clarifying this now
# since validate_moves will be split up eventually
module DetermineCheckAndMate
  include ValidateMoves

  def in_check?(color)
    team = color == "w" ? @white_pieces : @black_pieces
    king = team.find { |piece| piece.type == "K" }

    enemy_team = color == "w" ? @black_pieces : @white_pieces
    enemy_team.any? do |piece|
      taking_moves(piece).include? king.position
    end
  end

  def checkmate?(color)
  end
end
