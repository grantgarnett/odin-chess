require_relative "in_out"
require_relative "board"
require_relative "player"
require_relative "taking_moves"
require_relative "non_taking_moves"
require_relative "castling_validation"
require_relative "check_defense"
require_relative "draw_conditions"
require_relative "pinned_piece"

# This class is responsible for playing a game of
# chess, interacting with various other classes and
# objects in order to do so.
class Game # rubocop: disable Metrics/ClassLength
  include InOut

  attr_accessor :token, :computer
  attr_reader :chess_board

  def initialize
    @token = nil
    @computer = nil
    @chess_board = Board.new
    @current_player = Player.new("w")
    @other_player = Player.new("b")

    @taking = TakingMoves.new(@chess_board)
    @non_taking = NonTakingMoves.new(@chess_board)
    @castling_validation = CastlingValidation.new(@chess_board)
    @check_defense = CheckDefense.new(@taking, @non_taking)
    @draw_conditions = DrawConditions.new(@taking, @non_taking)
    @pinned_pieces = PinnedPiece.new(@taking, @non_taking)
  end

  def play_game
    computer ? play_computer : play_human
  end

  def switch_players
    @current_player, @other_player = @other_player, @current_player
  end

  def serialize
    obj = [@draw_conditions, @chess_board,
           @current_player, @other_player].map(&:serialize)
    obj.push(@token, @computer)

    JSON.dump(obj)
  end

  def unserialize(serialized_data)
    obj = JSON.parse(serialized_data)

    [@draw_conditions, @chess_board,
     @current_player, @other_player].each_with_index do |instance_var, i|
       instance_var.unserialize(obj[i])
     end

    @token = obj[4]
    @computer = obj[5]
  end

  def process_computer_turn
    process_computer_move
    @draw_conditions.update_repetition_counter(@current_player.color)
    switch_players
  end

  private

  def play_computer
    catch(:end) do
      loop do
        process_player_turn
        process_computer_turn
      end
    end
  end

  def process_computer_move
    if @draw_conditions.draw?(@current_player.color)
      draw_message
      throw(:end, 1)
    elsif @check_defense.in_check?(@current_player.color)
      computer_handle_check
    else
      computer_move
    end
  end

  def computer_handle_check
    valid_moves = @check_defense.check_defense(@current_player.color)

    if valid_moves.empty?
      throw(:end, 1)
    else
      move = valid_moves.sample
      orig_enem_team_count = enemy_team.count
      @chess_board.move_piece(move[0], move[1])
      process_fifty_move_rule(orig_enem_team_count != enemy_team.count, move[0])
    end
  end

  def computer_move
    color = @current_player.color
    valid_moves = generate_computer_moves(color)
    move = valid_moves.sample

    if %w[0-0 0-0-0].include? move
      @chess_board.castle(color, move)
    else
      @chess_board.move_piece(move[0], move[1])
    end
  end

  def generate_computer_moves(color)
    team = current_team

    moves = team.map do |piece|
      @pinned_pieces.valid_piece_moves_including_pins(piece).map do |move|
        [piece, move]
      end
    end.flatten(1).reject(&:empty?)

    moves.push "0-0" if @castling_validation.can_short_castle?(color)
    moves.push "0-0-0" if @castling_validation.can_long_castle?(color)

    moves
  end

  def play_human
    catch(:end) do
      loop do
        process_player_turn
      end
    end
  end

  def process_player_turn
    print_board(@chess_board.game_state, @current_player.color)
    process_player_move
    @draw_conditions.update_repetition_counter(@current_player.color)
    switch_players
  end

  def process_player_move
    if @draw_conditions.draw?(@current_player.color)
      draw_message
      throw(:end, 1)
    elsif @check_defense.in_check?(@current_player.color)
      handle_check
    else
      move_if_possible(take_move)
    end
  end

  def handle_check
    valid_moves = @check_defense.check_defense(@current_player.color)

    if valid_moves.empty?
      checkmate_message
      throw(:end, 1)
    else
      move_under_check(take_move, valid_moves)
    end
  end

  def move_under_check(desired_move, valid_moves)
    throw(:end, 0) if desired_move == "!"

    piece, move_pos = *find_piece_to_move(*desired_move)

    if piece.nil? || !valid_moves.include?([piece, move_pos])
      invalid_input_under_check_message
      move_under_check(take_move, valid_moves)
    else
      process_fifty_move_rule(desired_move[3], piece)
      @chess_board.move_piece(piece, move_pos)
    end
  end

  def move_if_possible(desired_move)
    if desired_move == "!"
      throw(:end, 0)
    elsif %w[0-0 0-0-0].include? desired_move
      castle_if_possible(desired_move)
    else
      standard_move_if_possible(desired_move)
    end
  end

  def castle_if_possible(desired_move)
    color = @current_player.color
    if @castling_validation.can_castle?(color, desired_move)
      @chess_board.castle(color, desired_move)
    else
      invalid_input_message
      move_if_possible(take_move)
    end
  end

  def standard_move_if_possible(desired_move)
    piece, move_pos = *find_piece_to_move(*desired_move)

    if piece.nil?
      invalid_input_message
      move_if_possible(take_move)
    else
      @chess_board.move_piece(piece, move_pos)
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

  def enemy_team
    if @current_player.color == "w"
      @chess_board.black_pieces
    else
      @chess_board.white_pieces
    end
  end

  def valid_pieces_for_move(possible_pieces, target_pos, taking) # rubocop: disable Metrics/MethodLength
    if taking == true
      possible_pieces.select do |piece|
        @taking.taking_moves(piece).include?(target_pos) &&
          can_make_move_if_pinned?(piece, target_pos)
      end
    else
      possible_pieces.select do |piece|
        @non_taking.non_taking_moves(piece).include?(target_pos) &&
          can_make_move_if_pinned?(piece, target_pos)
      end
    end
  end

  def can_make_move_if_pinned?(piece, target_pos)
    return true unless @pinned_pieces.pinned_piece?(piece)

    @pinned_pieces.valid_moves_under_pin(piece).include? target_pos
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

  def process_fifty_move_rule(taking, piece)
    # if taking
    if taking || piece.type == "p"
      @draw_conditions.increment_fifty_move_counter
    else
      @draw_conditions.reset_fifty_move_counter
    end
  end
end
