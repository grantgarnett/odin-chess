require_relative "non_taking_moves"

# This class is responsible for for determining
# whether a player of a particular color can
# perform a castling operation given the board state
class CastlingValidation < NonTakingMoves
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
      board.game_state[7][5] == "x" && board.game_state[7][6] == "x" &&
      short_castle_not_blocked?([7, 5], [7, 6], @board.black_pieces)
  end

  def can_black_short_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 7]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[0][5] == "x" && board.game_state[0][6] == "x" &&
      short_castle_not_blocked?([0, 5], [0, 6], @board.white_pieces)
  end

  def can_white_long_castle?
    king_starting_pos = [7, 4]
    rook_starting_pos = [7, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[7][1] == "x" &&
      board.game_state[7][2] == "x" &&
      board.game_state[7][3] == "x" &&
      long_castle_not_blocked?([7, 1], [7, 2], [7, 3], @board.black_pieces)
  end

  def can_black_long_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.game_state[0][1] == "x" &&
      board.game_state[0][2] == "x" &&
      board.game_state[0][3] == "x" &&
      long_castle_not_blocked?([0, 1], [0, 2], [0, 3], @board.white_pieces)
  end

  def short_castle_not_blocked?(space_one, space_two, enemy_team)
    enemy_team.none? do |piece|
      moves = non_taking_moves(piece)
      moves.include?(space_one) || moves.include?(space_two)
    end
  end

  def long_castle_not_blocked?(space_one, space_two, space_three, enemy_team)
    enemy_team.none? do |piece|
      moves = non_taking_moves(piece)
      moves.include?(space_one) ||
        moves.include?(space_two) ||
        moves.include?(space_three)
    end
  end
end
