require_relative "piece"

# This class is responsible for updating the state of the board
# and answering questions about the board state
class Board
  attr_reader :board

  def initialize
    @board = generate_board
  end

  def generate_board
    @board = [generate_back_row("b"),
              generate_pawns("b"),
              [nil, nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil, nil],
              generate_pawns("w"),
              generate_back_row("w")]
  end

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
end
