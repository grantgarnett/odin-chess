require_relative "validate_moves"

# This class is responsible for evaluating taking
# moves for a particular piece given the state of the board.
# This class does not evaluate whether or not a piece is pinned.
class TakingMoves < ValidateMoves # rubocop: disable Metrics/ClassLength
  def taking_moves(piece) # rubocop: disable Metrics/AbcSize
    case piece.type
    when "p" then taking_pawn_moves(piece.color, piece.position)
    when "R" then taking_rook_moves(piece.color, piece.position)
    when "B" then taking_bishop_moves(piece.color, piece.position)
    when "Q" then taking_queen_moves(piece.color, piece.position)
    when "N" then taking_knight_moves(piece.color, piece.position)
    when "K" then taking_king_moves(piece.color, piece.position)
    end
  end

  def en_passant_move(color, position)
    up_or_down = color == "w" ? -1 : 1

    # don't have to search every val since a maximum of one capture will be possible
    [-1, 1].each do |dir|
      next if spot_empty?([position[0], position[1] + dir])

      adjacent_piece = find_adjacent_piece_in_dir(position, dir)

      if adjacent_piece.color != color && adjacent_piece.type == "p" &&
         adjacent_piece.can_en_passant == true
        return [[position[0] + up_or_down, position[1] + dir]]
      end
    end

    []
  end

  def find_adjacent_piece_in_dir(pawn_pos, dir)
    board.game_state[pawn_pos[0]][pawn_pos[1] + dir]
  end

  def taking_pawn_moves(color, pos)
    valid_moves = pawn_taking_positions(color, pos).map do |move|
      move if can_take_at?(color, move)
    end

    valid_moves.union(en_passant_move(color, pos)).compact
  end

  def taking_rook_moves(color, pos)
    taking_up_and_down(color, pos)
      .union(taking_left_and_right(color, pos)).compact
  end

  def taking_bishop_moves(color, pos)
    taking_main_diagonal(color, pos)
      .union(taking_minor_diagonal(color, pos)).compact
  end

  def taking_queen_moves(color, pos)
    taking_rook_moves(color, pos)
      .union(taking_bishop_moves(color, pos)).compact
  end

  def taking_knight_moves(color, pos)
    moves = KNIGHT_MOVES.map do |move|
      possible_move = [pos[0] + move[0], pos[1] + move[1]]
      possible_move if can_take_at?(color, possible_move)
    end

    moves.compact
  end

  def taking_king_moves(color, pos)
    opposite_color = color == "w" ? "b" : "w"

    moves = KING_MOVES.map do |move|
      possible_move = [pos[0] + move[0], pos[1] + move[1]]
      possible_move if can_take_at?(color, possible_move)
    end

    moves.compact.difference(protected_pieces(opposite_color))
  end

  def taking_rec(color, pos, x_shift, y_shift)
    return [pos] if can_take_at?(color, pos)
    return [] unless can_move_without_taking_at?(pos)

    taking_rec(color, [pos[0] + x_shift, pos[1] + y_shift], x_shift, y_shift)
  end

  def taking_up_and_down(color, pos)
    taking_rec(color, [pos[0] - 1, pos[1]], -1, 0)
      .union(taking_rec(color, [pos[0] + 1, pos[1]], 1, 0))
  end

  def taking_left_and_right(color, pos)
    taking_rec(color, [pos[0], pos[1] - 1], 0, -1)
      .union(taking_rec(color, [pos[0], pos[1] + 1], 0, 1))
  end

  def taking_main_diagonal(color, pos)
    taking_rec(color, [pos[0] - 1, pos[1] - 1], -1, -1)
      .union(taking_rec(color, [pos[0] + 1, pos[1] + 1], 1, 1))
  end

  def taking_minor_diagonal(color, pos)
    taking_rec(color, [pos[0] + 1, pos[1] - 1], 1, -1)
      .union(taking_rec(color, [pos[0] - 1, pos[1] + 1], -1, 1))
  end

  def can_take_at?(color, pos)
    pos[0] >= 0 && pos[1] >= 0 &&
      !spot_empty?([pos[0],
                    pos[1]]) && (board.game_state[pos[0]][pos[1]].color != color)
  end

  def can_protect_at?(color, pos)
    pos[0] >= 0 && pos[1] >= 0 &&
      !spot_empty?([pos[0], pos[1]]) &&
      (board.game_state[pos[0]][pos[1]].color == color)
  end

  def protected_by_pawn(color, pieces)
    up_or_down = color == "w" ? -1 : 1
    pawns = pieces.filter { |piece| piece.type == "p" }

    pawns.map do |pawn|
      [-1, 1].map do |dir|
        move = [pawn.position[0] + up_or_down, pawn.position[1] + dir]
        move if can_protect_at?(color, move)
      end.flatten(1).compact
    end
  end

  def protected_by_king(color)
    king = find_king(color)

    KING_MOVES.map do |dir|
      move = [king.position[0] + dir[0], king.position[1] + dir[1]]
      move if can_protect_at?(color, move)
    end
  end

  def protected_by_other(color, pieces)
    opposite_color = color == "w" ? "b" : "w"

    protecting_pieces = pieces.filter do |piece|
      piece.type != "K" && piece.type != "p"
    end

    protecting_pieces.map do |piece|
      piece.color = opposite_color
      return_arr = taking_moves(piece)
      piece.color = color
      return_arr
    end.flatten(1)
  end

  def protected_pieces(color)
    pieces = color == "w" ? board.white_pieces : board.black_pieces

    protected_by_pawn(color, pieces)
      .union(protected_by_king(color))
      .union(protected_by_other(color, pieces))
  end
end
