require_relative "validate_moves"

# This class is responsible for for determining
# whether a player of a particular color can
# perform a castling operation given the board state
class CastlingValidation < ValidateMoves
  def can_castle?(color, long_or_short)
    if long_or_short == "0-0"
      can_short_castle?(color)
    elsif long_or_short == "0-0-0"
      can_long_castle?(color)
    end
  end

  def can_short_castle?(color)
    if color == "w"
      can_white_short_castle?
    elsif color == "b"
      can_black_short_castle?
    end
  end

  def can_long_castle?(color)
    if color == "w"
      can_white_long_castle?
    elsif color == "b"
      can_black_long_castle?
    end
  end

  def can_castle_at?(start_pos, type)
    !spot_empty?(start_pos) &&
      board.game_state[start_pos[0]][start_pos[1]].type == type &&
      board.game_state[start_pos[0]][start_pos[1]].can_castle
  end

  def can_white_short_castle?
    king_starting_pos = [7, 4]
    rook_starting_pos = [7, 7]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[7][5] == "x" && board.game_state[7][6] == "x"
  end

  def can_black_short_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 7]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[0][5] == "x" && board.game_state[0][6] == "x"
  end

  def can_white_long_castle?
    king_starting_pos = [7, 4]
    rook_starting_pos = [7, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[7][1] == "x" &&
      board.game_state[7][2] == "x" &&
      board.game_state[7][3] == "x"
  end

  def can_black_long_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[0][1] == "x" &&
      board.game_state[0][2] == "x" &&
      board.game_state[0][3] == "x"
  end
end
