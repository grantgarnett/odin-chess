require_relative "piece"
require_relative "validate_moves"

# This class is responsible for updating the state of the board
# and answering questions about the board state
class Board
  include ValidateMoves

  attr_reader :board, :white_pieces, :black_pieces

  def initialize
    @board = generate_board
    @white_pieces = generate_white_piece_arr
    @black_pieces = generate_black_piece_arr
  end

  def generate_board
    @board = [generate_back_row("b"),
              generate_pawns("b"),
              %w[x x x x x x x x],
              %w[x x x x x x x x],
              %w[x x x x x x x x],
              %w[x x x x x x x x],
              generate_pawns("w"),
              generate_back_row("w")]
  end

  def move_piece(piece, target)
    if board[target[0]][target[1]] == "x"
      non_taking_move(piece, target)
    else
      taking_move(piece, target)
    end
  end

  private

  def generate_pawns(color)
    row = color == "w" ? 6 : 1
    pawn_arr = []

    8.times do |i|
      pawn_arr << Piece.new(color, "p", [row, i])
    end

    pawn_arr
  end

  def generate_back_row(color)
    row = color == "w" ? 7 : 0

    [Piece.new(color, "R", [row, 0]), Piece.new(color, "N", [row, 1]),
     Piece.new(color, "B", [row, 2]), Piece.new(color, "Q", [row, 3]),
     Piece.new(color, "K", [row, 4]), Piece.new(color, "B", [row, 5]),
     Piece.new(color, "N", [row, 6]), Piece.new(color, "R", [row, 7])]
  end

  def generate_white_piece_arr
    @board.map do |row|
      row.select do |el|
        el.color == "w" unless el == "x"
      end
    end.flatten.compact
  end

  def generate_black_piece_arr
    @board.map do |row|
      row.select do |el|
        el.color == "b" unless el == "x"
      end
    end.flatten.compact
  end

  def non_taking_move(piece, target)
    position_before = piece.position
    piece.position = target

    @board[target[0]][target[1]] = piece
    @board[position_before[0]][position_before[1]] = "x"
  end

  def taking_move(piece, target)
    taken_piece = @board[target[0]][target[1]]

    position_before = piece.position
    piece.position = target

    @board[target[0]][target[1]] = piece
    @board[position_before[0]][position_before[1]] = "x"

    remove_from_team_arr(taken_piece)
  end

  def remove_from_team_arr(piece)
    team_arr = piece.color == "w" ? @white_pieces : @black_pieces
    team_arr.delete(piece)
  end
end
