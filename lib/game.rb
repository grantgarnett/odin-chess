require_relative "in_out"
require_relative "board"
require_relative "player"

# description to be added
class Game
  include InOut

  def initialize
    @chess_board = Board.new
    @current_player = Player.new("w")
    @other_player = Player.new("b")
    play_game
  end

  def play_game
    loop do
      print_board(@chess_board.board)

      move_if_possible(take_move)

      @current_player, @other_player = @other_player, @current_player
    end
  end

  private

  def move_if_possible(desired_move)
    if %w[0-0 0-0-0].include? desired_move
      castle_if_possible(desired_move)
    else
      standard_move_if_possible(desired_move)
    end
  end

  def castle_if_possible(desired_move)
    color = @current_player.color
    if @chess_board.can_castle?(color, desired_move)
      @chess_board.castle(color, desired_move)
    else
      invalid_input_message
      move_if_possible(take_move)
    end
  end

  def standard_move_if_possible(desired_move)
    piece, desired_move = *find_piece_to_move(*desired_move)
    if piece.nil?
      invalid_input_message
      move_if_possible(take_move)
    else
      @chess_board.move_piece(piece, desired_move)
    end
  end

  def find_piece_to_move(type, start_pos, target_pos, taking)
    team = current_team

    pieces_of_type = team.select { |piece| piece.type == type }
    possible_pieces = filter_by_start_pos(pieces_of_type, start_pos)
    options = valid_pieces_for_move(possible_pieces, target_pos, taking)

    return [nil, target_pos] unless options.size == 1

    options.push target_pos
  end

  def current_team
    if @current_player.color == "w"
      @chess_board.white_pieces
    else
      @chess_board.black_pieces
    end
  end

  def valid_pieces_for_move(possible_pieces, target_pos, taking)
    if taking == true
      possible_pieces.select do |piece|
        @chess_board.taking_moves(piece).include? target_pos
      end
    else
      possible_pieces.select do |piece|
        @chess_board.non_taking_moves(piece).include? target_pos
      end
    end
  end

  def filter_by_start_pos(options, start_pos)
    unless start_pos[0].nil?
      options.select! { |piece| piece.position[0] == start_pos[0] }
    end

    unless start_pos[1].nil?
      options.select! { |piece| piece.position[1] == start_pos[1] }
    end

    options
  end
end

Game.new
