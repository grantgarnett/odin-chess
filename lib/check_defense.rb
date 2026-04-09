require_relative "taking_moves"
require_relative "non_taking_moves"

# This class returns valid moves for
# a player to make when in check. These
# methods assume that a player is in check.
class CheckDefense
  attr_reader :taking, :non_taking, :board

  def initialize(taking_move_calculator, non_taking_move_calculator)
    @taking = taking_move_calculator
    @non_taking = non_taking_move_calculator
    @board = @taking.board
  end

  def in_check?(color)
    team = color == "w" ? @board.white_pieces : @board.black_pieces
    king = team.find { |piece| piece.type == "K" }

    enemy_team = color == "w" ? @board.black_pieces : @board.white_pieces
    enemy_team.any? do |piece|
      @taking.taking_moves(piece).include? king.position
    end
  end

  def check_defense(color)
    king = @non_taking.find_king(color)
    enemy_team = color == "w" ? @board.black_pieces : @board.white_pieces
    checking_pieces = find_checking_pieces(king, enemy_team)

    if checking_pieces.size > 1
      defending_king_moves(king).compact
    elsif %w[N p].include? checking_pieces[0].type
      defending_without_blocking_moves(king, checking_pieces[0])
    else
      defending_with_blocking_moves(king, checking_pieces[0]).compact
    end
  end

  def find_checking_pieces(king, enemy_team)
    enemy_team.select do |piece|
      @taking.taking_moves(piece).include? king.position
    end
  end

  def defending_with_blocking_moves(king, checking_piece)
    defending_without_blocking_moves(king, checking_piece)
      .union(blocking_moves(king, checking_piece))
  end

  # assumes checking piece is B, R, or Q
  def find_blocking_squares(king, checking_piece) # rubocop: disable Metrics/AbcSize
    x_offset = convert_to_dir(king.position[0] - checking_piece.position[0])
    y_offset = convert_to_dir(king.position[1] - checking_piece.position[1])

    @non_taking.non_taking_rec([checking_piece.position[0] + x_offset,
                                checking_piece.position[1] + y_offset],
                               x_offset, y_offset)
  end

  private

  def defending_without_blocking_moves(king, checking_piece)
    defending_king_moves(king)
      .union(defending_standard_taking_moves(checking_piece))
      .union(defense_by_en_passant(checking_piece)).compact
  end

  def defending_king_moves(king)
    convert_to_return_format(king, @taking.taking_moves(king))
      .union(convert_to_return_format(king, @non_taking.non_taking_moves(king)))
  end

  def convert_to_return_format(piece, moves)
    moves.map { |move| [piece, move] }
  end

  def defending_standard_taking_moves(checking_piece)
    team = checking_piece.color == "w" ? @board.black_pieces : @board.white_pieces
    checking_piece_pos = checking_piece.position

    team.map do |piece|
      if @taking.taking_moves(piece).include? checking_piece_pos
        [piece, checking_piece_pos]
      end
    end.compact
  end

  # this method is only concerned with taking the piece
  # calling check using en passant. blocking a check via
  # en passant is handled naturally in blocking_moves
  def defense_by_en_passant(checking_piece)
    return [] unless checking_piece.type == "p" && checking_piece.can_en_passant

    team = checking_piece.color == "w" ? @board.black_pieces : @board.white_pieces
    pawns = team.select { |piece| piece.type == "p" }

    # since two could take
    pawns.map do |pawn|
      move = @taking.en_passant_move(pawn.color, pawn.position)
      [pawn, move] unless move.empty?
    end
  end

  def blocking_moves(king, checking_piece)
    blocking_squares = find_blocking_squares(king, checking_piece)
    team = king.color == "w" ? @board.white_pieces : @board.black_pieces

    team.map do |piece|
      moves = @non_taking.non_taking_moves(piece)

      blocking_squares.map do |square|
        [piece, square] if moves.include? square
      end
    end.flatten(1).compact
  end

  def convert_to_dir(offset)
    if offset.positive?
      1
    elsif offset.negative?
      -1
    else
      0
    end
  end
end
