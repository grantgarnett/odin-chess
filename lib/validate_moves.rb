# This class handles functionality for validating chess moves
# Moves that involve taking are separated into their own
# context, due to the use of algebraic notation in our
# implementation of chess
class ValidateMoves
  attr_reader :board

  KNIGHT_MOVES = [[1, 2], [-1, 2], [2, 1], [-2, 1],
                  [1, -2], [-1, -2], [2, -1], [-2, -1]].freeze

  KING_MOVES = [[1, -1], [1, 0], [1, 1], [0, -1],
                [0, 1], [-1, -1], [-1, 0], [-1, 1]].freeze

  def initialize(board)
    @board = board
  end

  def find_king(color)
    team = color == "w" ? board.white_pieces : board.black_pieces
    team.find { |piece| piece.type == "K" }
  end

  private

  def can_move_without_taking_at?(move)
    move[0].between?(0, 7) && move[1].between?(0, 7) &&
      board.game_state[move[0]][move[1]] == "x"
  end

  def spot_empty?(pos) # rubocop: disable Metrics/AbcSize
    board.game_state[pos[0]].nil? ||
      board.game_state[pos[0]][pos[1]].nil? ||
      board.game_state[pos[0]][pos[1]] == "x"
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
end
