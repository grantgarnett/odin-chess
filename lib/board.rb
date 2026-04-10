require_relative "piece"
require_relative "validate_moves"
require_relative "in_out"

# This class is responsible for updating the state of the board
# and answering questions about the board state
class Board # rubocop: disable Metrics/ClassLength
  include InOut

  attr_reader :game_state, :white_pieces, :black_pieces, :fifty_move_counter

  def initialize
    @game_state = generate_board
    @white_pieces = generate_white_piece_arr
    @black_pieces = generate_black_piece_arr
  end

  def move_piece(piece, target)
    update_attributes_after_move(piece, target)

    if taking_by_en_passant?(piece, target)
      en_passant(piece, target)
    elsif game_state[target[0]][target[1]] == "x"
      non_taking_move(piece, target)
    else
      taking_move(piece, target)
    end

    promote_pawn_if_possible(target) if piece.type == "p"
  end

  def castle(color, long_or_short)
    case [color, long_or_short]
    when %w[w 0-0] then white_short_castle
    when %w[w 0-0-0] then white_long_castle
    when %w[b 0-0] then black_short_castle
    when %w[b 0-0-0] then black_long_castle
    end
  end

  private

  def generate_board
    [generate_back_row("b"),
     generate_pawns("b"),
     %w[x x x x x x x x],
     %w[x x x x x x x x],
     %w[x x x x x x x x],
     %w[x x x x x x x x],
     generate_pawns("w"),
     generate_back_row("w")]
  end

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
    game_state.map do |row|
      row.select do |el|
        el.color == "w" unless el == "x"
      end
    end.flatten.compact
  end

  def generate_black_piece_arr
    game_state.map do |row|
      row.select do |el|
        el.color == "b" unless el == "x"
      end
    end.flatten.compact
  end

  def non_taking_move(piece, target)
    position_before = piece.position
    piece.position = target

    game_state[target[0]][target[1]] = piece
    game_state[position_before[0]][position_before[1]] = "x"
  end

  def taking_move(piece, target)
    remove_taken_piece(target)

    position_before = piece.position
    piece.position = target

    game_state[target[0]][target[1]] = piece
    game_state[position_before[0]][position_before[1]] = "x"
  end

  def promote_pawn_if_possible(pawn_pos)
    promote_pawn if [0, 7].include? pawn_pos[0]
  end

  def promote_pawn(pawn_pos)
    @game_state[pawn_pos[0]][pawn_pos[1]].type = prompt_pawn_promotion
  end

  def en_passant(piece, target)
    @fifty_move_counter = 0
    non_taking_move(piece, target)
    direction_of_removal = piece.color == "w" ? 1 : -1
    taken_piece = game_state[target[0] + direction_of_removal][target[1]]

    game_state[target[0] + direction_of_removal][target[1]] = "x"
    remove_from_team_arr(taken_piece)
  end

  def remove_taken_piece(position)
    taken_piece = game_state[position[0]][position[1]]
    remove_from_team_arr(taken_piece)
  end

  def remove_from_team_arr(piece)
    team_arr = piece.color == "w" ? @white_pieces : @black_pieces
    team_arr.delete(piece)
  end

  def update_attributes_after_move(piece, target)
    team = piece.color == "w" ? @white_pieces : @black_pieces
    disable_en_passant(team)

    if piece.type == "p" && piece.move_by_two == true
      update_after_first_pawn_move(piece, target)
    elsif %w[K R].include?(piece.type) && piece.can_castle == true
      piece.can_castle = false
    end
  end

  def disable_en_passant(team)
    team.select { |piece| piece.type == "p" }.each do |pawn|
      pawn.can_en_passant = false if pawn.can_en_passant == true
    end
  end

  def update_after_first_pawn_move(piece, target)
    piece.move_by_two = false
    piece.can_en_passant = true if (target[0] - piece.position[0]).abs == 2
  end

  def taking_by_en_passant?(piece, target)
    piece.type == "p" &&
      piece.position[1] != target[1] &&
      game_state[target[0]][target[1]] == "x"
  end

  def white_short_castle
    move_piece(game_state[7][7], [7, 5])
    move_piece(game_state[7][4], [7, 6])
  end

  def white_long_castle
    move_piece(game_state[7][0], [7, 3])
    move_piece(game_state[7][4], [7, 2])
  end

  def black_short_castle
    move_piece(game_state[0][7], [0, 5])
    move_piece(game_state[0][4], [0, 6])
  end

  def black_long_castle
    move_piece(game_state[0][0], [0, 3])
    move_piece(game_state[0][4], [0, 2])
  end
end
