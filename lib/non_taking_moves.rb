require_relative "validate_moves"

class NonTakingMoves < ValidateMoves
  def non_taking_moves(piece) # rubocop: disable Metrics/AbcSize
    case piece.type
    when "p" then non_taking_pawn_moves(piece.color, piece.position,
                                        piece.move_by_two)
    when "R" then non_taking_rook_moves(piece.position)
    when "B" then non_taking_bishop_moves(piece.position)
    when "Q" then non_taking_queen_moves(piece.position)
    when "N" then non_taking_knight_moves(piece.position)
    when "K" then non_taking_king_moves(piece.color, piece.position)
    end
  end

  def non_taking_rec(pos, x_shift, y_shift)
    return [] unless can_move_without_taking_at?(pos)

    next_move = non_taking_rec([pos[0] + x_shift, pos[1] + y_shift],
                               x_shift, y_shift)

    next_move.empty? ? [pos] : next_move.push(pos)
  end

  def non_taking_pawn_moves(color, pos, can_move_by_two)
    up_or_down = color == "w" ? -1 : 1
    return_arr = []

    if can_move_from_pos_to?(pos, up_or_down, 0)
      return_arr << [pos[0] + up_or_down, pos[1]]
      if can_move_by_two && can_move_from_pos_to?(pos, 2 * up_or_down, 0)
        return_arr << [pos[0] + (2 * up_or_down), pos[1]]
      end
    end

    return_arr
  end

  def non_taking_rook_moves(pos)
    non_taking_up_and_down(pos).union(non_taking_left_and_right(pos))
  end

  def non_taking_bishop_moves(pos)
    non_taking_main_diagonal(pos).union(non_taking_minor_diagonal(pos))
  end

  def non_taking_queen_moves(pos)
    non_taking_rook_moves(pos).union(non_taking_bishop_moves(pos))
  end

  def non_taking_knight_moves(pos)
    valid_dirs = KNIGHT_MOVES.select do |move|
      can_move_without_taking_at?([pos[0] + move[0], pos[1] + move[1]])
    end

    valid_dirs.map { |move| [pos[0] + move[0], pos[1] + move[1]] }
  end

  def non_taking_king_moves(color, pos)
    invalid_moves = invalid_non_taking_king_moves(color)

    possible_moves = KING_MOVES.map do |move|
      [pos[0] + move[0], pos[1] + move[1]]
    end

    possible_moves.select do |move|
      can_move_without_taking_at?(move) && !invalid_moves.include?(move)
    end
  end

  def can_move_from_pos_to?(pos, x_shift, y_shift)
    x = pos[0]
    y = pos[1]

    can_move_without_taking_at?([x + x_shift, y + y_shift])
  end

  def non_taking_up_and_down(pos)
    non_taking_rec([pos[0] - 1, pos[1]], -1, 0)
      .union(non_taking_rec([pos[0] + 1, pos[1]], 1, 0))
  end

  def non_taking_left_and_right(pos)
    non_taking_rec([pos[0], pos[1] - 1], 0, -1)
      .union(non_taking_rec([pos[0], pos[1] + 1], 0, 1))
  end

  def non_taking_main_diagonal(pos)
    non_taking_rec([pos[0] - 1, pos[1] - 1], -1, -1)
      .union(non_taking_rec([pos[0] + 1, pos[1] + 1], 1, 1))
  end

  def non_taking_minor_diagonal(pos)
    non_taking_rec([pos[0] + 1, pos[1] - 1], 1, -1)
      .union(non_taking_rec([pos[0] - 1, pos[1] + 1], -1, 1))
  end

  def invalid_non_taking_king_moves(color)
    enemy_color = color == "w" ? "b" : "w"

    enemy_standard_moves = invalid_king_moves_from_standard_pieces(color)

    # must calculate enemy king moves separately to prevent infinite recursion
    enemy_king_moves = invalid_king_moves_from_enemy_king(enemy_color)

    enemy_standard_moves.push(enemy_king_moves).uniq.flatten(1).compact
  end

  def invalid_king_moves_from_standard_pieces(color)
    enemy_pieces = color == "w" ? board.black_pieces : board.white_pieces
    enemy_color = color == "w" ? "b" : "w"
    enemy_pieces.map do |piece|
      if %w[K p].include?(piece.type)
        pawn_taking_positions(enemy_color, piece.position) if piece.type == "p"
      else
        non_taking_moves(piece)
      end
    end
  end

  def invalid_king_moves_from_enemy_king(enemy_color)
    enemy_king_pos = find_king(enemy_color).position

    KING_MOVES.map do |move_dir|
      x_coord = enemy_king_pos[0] + move_dir[0]
      y_coord = enemy_king_pos[1] + move_dir[1]

      [x_coord, y_coord] if x_coord.between?(0, 7) && y_coord.between?(0, 7)
    end
  end
end
