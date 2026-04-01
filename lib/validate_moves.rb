# This class handles functionality for validating chess moves
# Moves that involve taking are separated into their own
# context, due to the use of algebraic notation in our
# implementation of chess
class ValidateMoves # rubocop: disable Metrics/ClassLength
  attr_reader :board

  KNIGHT_MOVES = [[1, 2], [-1, 2], [2, 1], [-2, 1],
                  [1, -2], [-1, -2], [2, -1], [-2, -1]].freeze

  KING_MOVES = [[1, -1], [1, 0], [1, 1], [0, -1],
                [0, 1], [-1, -1], [-1, 0], [-1, 1]].freeze

  def initialize(board)
    @board = board
  end

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

  def can_castle?(color, long_or_short)
    if long_or_short == "0-0"
      can_short_castle?(color)
    elsif long_or_short == "0-0-0"
      can_long_castle?(color)
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
    board.board[pawn_pos[0]][pawn_pos[1] + dir]
  end

  def non_taking_rec(pos, x_shift, y_shift)
    return [] unless can_move_without_taking_at?(pos)

    next_move = non_taking_rec([pos[0] + x_shift, pos[1] + y_shift],
                               x_shift, y_shift)

    next_move.empty? ? [pos] : next_move.push(pos)
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
    invalid_moves = invalid_non_taking_king_moves(color)

    possible_moves = KING_MOVES.map do |move|
      [pos[0] + move[0], pos[1] + move[1]]
    end

    possible_moves.select do |move|
      can_move_without_taking_at?(move) && !invalid_moves.include?(move)
    end
  end

  def can_move_without_taking_at?(move)
    move[0].between?(0, 7) && move[1].between?(0, 7) &&
      board.board[move[0]][move[1]] == "x"
  end

  def spot_empty?(pos)
    board.board[pos[0]].nil? ||
      board.board[pos[0]][pos[1]].nil? ||
      board.board[pos[0]][pos[1]] == "x"
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

  def find_king(color)
    team = color == "w" ? board.white_pieces : board.black_pieces
    team.find { |piece| piece.type == "K" }
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

  def pawn_taking_positions(color, pos)
    up_or_down = color == "w" ? -1 : 1

    [-1, 1].map do |left_or_right|
      if (pos[0] + up_or_down).between?(0, 7) &&
         (pos[1] + left_or_right).between?(0, 7)
        [pos[0] + up_or_down, pos[1] + left_or_right]
      end
    end.compact
  end

  def can_take_at?(color, pos)
    pos[0] >= 0 && pos[1] >= 0 &&
      !spot_empty?([pos[0],
                    pos[1]]) && (board.board[pos[0]][pos[1]].color != color)
  end

  def can_protect_at?(color, pos)
    pos[0] >= 0 && pos[1] >= 0 &&
      !spot_empty?([pos[0],
                    pos[1]]) && (board.board[pos[0]][pos[1]].color == color)
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
    !spot_empty?(start_pos) && board.board[start_pos[0]][start_pos[1]].type == type &&
      board.board[start_pos[0]][start_pos[1]].can_castle
  end

  def can_white_short_castle?
    king_starting_pos = [7, 4]
    rook_starting_pos = [7, 7]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.board[7][5] == "x" && board.board[7][6] == "x"
  end

  def can_black_short_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 7]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.board[0][5] == "x" && board.board[0][6] == "x"
  end

  def can_white_long_castle?
    king_starting_pos = [7, 4]
    rook_starting_pos = [7, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.board[7][1] == "x" && board.board[7][2] == "x" && board.board[7][3] == "x"
  end

  def can_black_long_castle?
    king_starting_pos = [0, 4]
    rook_starting_pos = [0, 0]

    can_castle_at?(king_starting_pos, "K") &&
      can_castle_at?(rook_starting_pos, "R") &&
      board.board[0][1] == "x" && board.board[0][2] == "x" && board.board[0][3] == "x"
  end
end
