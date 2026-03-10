require_relative "piece"

# This class is responsible for updating the state of the board
# and answering questions about the board state
class Board
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

  private

  def generate_pawns(color)
    [Piece.new(color, "p"), Piece.new(color, "p"), Piece.new(color, "p"),
     Piece.new(color, "p"), Piece.new(color, "p"), Piece.new(color, "p"),
     Piece.new(color, "p"), Piece.new(color, "p")]
  end

  def generate_back_row(color)
    [Piece.new(color, "R"), Piece.new(color, "N"), Piece.new(color, "B"),
     Piece.new(color, "Q"), Piece.new(color, "K"), Piece.new(color, "B"),
     Piece.new(color, "N"), Piece.new(color, "R")]
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
end
