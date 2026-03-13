# This class handles functionality for validating chess moves
# Moves that involve taking are separated into their own
# context, due to the use of algebraic notation in our
# implementation of chess
module ValidateMoves
  KNIGHT_MOVES = [[1, 2], [-1, 2], [2, 1], [-2, 1],
                  [1, -2], [-1, -2], [2, -1], [-2, -1]].freeze

  KING_MOVES = [[1, -1], [1, 0], [1, 1], [0, -1],
                [0, 1], [-1, -1], [-1, 0], [-1, 1]].freeze

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

  private

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
    invalid_moves = invalid_king_moves_without_taking_for(color)

    possible_moves = KING_MOVES.map do |move|
      [pos[0] + move[0], pos[1] + move[1]]
    end

    possible_moves.select do |move|
      can_move_without_taking_at?(move) && !invalid_moves.include?(move)
    end
  end

  def can_move_without_taking_at?(pos)
    pos[0] >= 0 && pos[1] >= 0 &&
      !@board[pos[0]].nil? && @board[pos[0]][pos[1]] == "x"
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

  def non_taking_rec(pos, x_shift, y_shift)
    return [] unless can_move_without_taking_at?(pos)

    next_move = non_taking_rec([pos[0] + x_shift, pos[1] + y_shift],
                               x_shift, y_shift)

    next_move.empty? ? [pos] : next_move.push(pos)
  end

  def invalid_king_moves_without_taking_for(color) # rubocop: disable Metrics/AbcSize
    enemy_pieces = color == "w" ? @black_pieces : @white_pieces

    invalid_moves = enemy_pieces.map do |piece|
      non_taking_moves(piece) unless piece.type == "K"
    end

    puts "#{invalid_moves}, this ran"

    enemy_king_pos = find_king(enemy_pieces).position
    enemy_king_moves = KING_MOVES.map do |move_dir|
      [enemy_king_pos[0] + move_dir[0], enemy_king_pos[1] + move_dir[1]]
    end

    invalid_moves.push(enemy_king_moves).uniq
  end

  def find_king(team_pieces)
    team_pieces.find { |piece| piece.type == "K" }
  end
end
