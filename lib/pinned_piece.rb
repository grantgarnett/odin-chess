require_relative "taking_moves"
require_relative "non_taking_moves"

# This class includes methods for determining
# if a piece is pinned and valid potential moves
# for a piece that is (returning taking and non taking
# moves along the direction of pin). This class does
# not take into account the actual moveset of the piece.
class PinnedPiece
  attr_reader :taking, :non_taking, :board

  DIAGONAL_PIN_DIRS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze
  FLAT_PIN_DIRS = [[-1, 0], [1, 0], [0, -1], [0, 1]].freeze

  def initialize(taking_move_calculator, non_taking_move_calculator)
    @taking = taking_move_calculator
    @non_taking = non_taking_move_calculator
    @board = @taking.board
  end

  def pinned_piece?(piece)
    king = @taking.find_king(piece.color)
    enemy_color = piece.color == "w" ? "b" : "w"

    pinned_along_diagonal?(piece, king, enemy_color) ||
      pinned_along_flat_lines?(piece, king, enemy_color)
  end

  def valid_moves_under_pin(piece)
    king = @taking.find_king(piece.color)
    row_diff = piece.position[0] - king.position[0]

    if row_diff.positive?
      pin_moves_with_positive_row_diff(piece, king)
    elsif row_diff.negative?
      pin_moves_with_negative_row_diff(piece, king)
    else
      left_and_right_moves(piece)
    end
  end

  private

  def pinned_along_diagonal?(piece, king, enemy_color)
    king_pos = king.position
    piece_pos = piece.position

    dir_from_king = diagonal_dir_from_king(piece_pos, king_pos, enemy_color)
    enemy_pos = look_in_dir_from_piece(piece_pos, piece.color,
                                       dir_from_king)
    return false if enemy_pos.empty?

    if %w[B Q].include? @board.game_state[enemy_pos[0]][enemy_pos[1]].type
      return true
    end

    false
  end

  def pinned_along_flat_lines?(piece, king, enemy_color)
    king_pos = king.position
    piece_pos = piece.position

    dir_from_king = flat_dir_from_king(piece_pos, king_pos, enemy_color)
    enemy_pos = look_in_dir_from_piece(piece_pos, piece.color,
                                       dir_from_king)
    return false if enemy_pos.empty?

    if %w[R Q].include? @board.game_state[enemy_pos[0]][enemy_pos[1]].type
      return true
    end

    false
  end

  def diagonal_dir_from_king(piece_pos, king_pos, enemy_color)
    DIAGONAL_PIN_DIRS.find do |dir|
      x_dir = dir[0]
      y_dir = dir[1]

      piece_pos == look_in_dir_from_pos(enemy_color, king_pos, x_dir, y_dir)
    end
  end

  def flat_dir_from_king(piece_pos, king_pos, enemy_color)
    FLAT_PIN_DIRS.find do |dir|
      x_dir = dir[0]
      y_dir = dir[1]

      piece_pos == look_in_dir_from_pos(enemy_color, king_pos, x_dir, y_dir)
    end
  end

  def look_in_dir_from_pos(color, pos, x_dir, y_dir)
    @taking.taking_rec(color, [pos[0] + x_dir, pos[1] + y_dir], x_dir,
                       y_dir).flatten(1)
  end

  def look_in_dir_from_piece(piece_pos, color, dir_from_king)
    return [] if dir_from_king.nil?

    look_in_dir_from_pos(color, piece_pos, dir_from_king[0], dir_from_king[1])
  end

  def pin_moves_with_positive_row_diff(piece, king)
    col_diff = piece.position[1] - king.position[1]

    if col_diff.positive?
      main_diagonal_moves(piece)
    elsif col_diff.negative?
      minor_diagonal_moves(piece)
    else
      up_and_down_moves(piece)
    end
  end

  def pin_moves_with_negative_row_diff(piece, king)
    col_diff = piece.position[1] - king.position[1]

    if col_diff.positive?
      minor_diagonal_moves(piece)
    elsif col_diff.negative?
      main_diagonal_moves(piece)
    else
      up_and_down_moves(piece)
    end
  end

  def left_and_right_moves(piece)
    @taking.taking_left_and_right(piece.color, piece.position).union(
      @non_taking.non_taking_left_and_right(piece.position)
    )
  end

  def up_and_down_moves(piece)
    @taking.taking_up_and_down(piece.color, piece.position).union(
      @non_taking.non_taking_up_and_down(piece.position)
    )
  end

  def main_diagonal_moves(piece)
    @taking.taking_main_diagonal(piece.color, piece.position).union(
      @non_taking.non_taking_main_diagonal(piece.position)
    )
  end

  def minor_diagonal_moves(piece)
    @taking.taking_minor_diagonal(piece.color, piece.position).union(
      @non_taking.non_taking_minor_diagonal(piece.position)
    )
  end
end
