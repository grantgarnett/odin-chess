require_relative "in_out"
require_relative "board"
require_relative "player"
require_relative "taking_moves"
require_relative "non_taking_moves"
require_relative "castling_validation"
require_relative "check_defense"

# description to be added
class Game # rubocop: disable Metrics/ClassLength
  include InOut

  attr_reader :chess_board

  def initialize # rubocop: disable Metrics/MethodLength
    @chess_board = Board.new
    @current_player = Player.new("w")
    @other_player = Player.new("b")

    @taking = TakingMoves.new(@chess_board)
    @non_taking = NonTakingMoves.new(@chess_board)
    @castling_validation = CastlingValidation.new(@chess_board)
    @check_defense = CheckDefense.new(@taking, @non_taking)

    @last_white_game_state = nil
    @second_last_white_game_state = nil
    @last_black_game_state = nil
    @second_last_black_game_state = nil
    @white_modulo = 0
    @black_modulo = 0
    @white_counter_one = 0
    @white_counter_two = 0
    @black_counter_one = 0
    @black_counter_two = 0
  end

  def play_game
    loop do
      print_board(@chess_board.game_state)
      update_repetition_counter
      process_current_turn
      switch_players
    end
  end

  def stalemate?
    team = current_team

    if team.all? { |piece| %w[K p].include?(piece.type) }
      return team.all? do |piece|
        @taking.taking_moves(piece).empty? &&
        @non_taking.non_taking_moves(piece).empty?
      end
    end

    false
  end

  def switch_players
    @current_player, @other_player = @other_player, @current_player
  end

  private

  def process_current_turn
    if draw?
      draw_message
      exit
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
      exit
    else
      move_under_check(take_move, valid_moves)
    end
  end

  def move_under_check(desired_move, valid_moves)
    piece, move_pos = *find_piece_to_move(*desired_move)

    if piece.nil? || !valid_moves.include?([piece, move_pos])
      invalid_input_under_check_message
      move_under_check(take_move, valid_moves)
    else
      @chess_board.move_piece(piece, move_pos)
    end
  end

  def move_if_possible(desired_move)
    if %w[0-0 0-0-0].include? desired_move
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

  def valid_pieces_for_move(possible_pieces, target_pos, taking)
    if taking == true
      possible_pieces.select do |piece|
        @taking.taking_moves(piece).include? target_pos
      end
    else
      possible_pieces.select do |piece|
        @non_taking.non_taking_moves(piece).include? target_pos
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

  def draw?
    draw_by_fifty_move_rule? ||
      draw_by_threefold_repetition? ||
      stalemate?
  end

  def draw_by_threefold_repetition?
    print "white counter one: #{@white_counter_one}\n"
    print "white counter two: #{@white_counter_two}\n"
    print "black counter one: #{@black_counter_one}\n"
    print "black counter two: #{@black_counter_two}\n"
    print "stalemate? #{stalemate?}\n"

    @white_counter_one == 3 ||
      @white_counter_two == 3 ||
      @black_counter_one == 3 ||
      @black_counter_two == 3 ||
      @black_repetition_counter == 3
  end

  def draw_by_fifty_move_rule?
    @chess_board.fifty_move_counter >= 50
  end

  def update_repetition_counter
    if @current_player.color == "w"
      update_white_repetition_counter
    else
      update_black_repetition_counter
    end
  end

  def update_white_repetition_counter
    if @white_modulo.zero?
      update_white_counter_one
    else
      update_white_counter_two
    end

    @white_modulo = 1 - @white_modulo
  end

  def update_white_counter_one
    if @second_last_white_game_state == @chess_board.game_state
      @white_counter_one += 1
    else
      @white_counter_one = 0
      @second_last_white_game_state = @chess_board.game_state.map(&:dup)
    end
  end

  def update_white_counter_two
    if @last_white_game_state == @chess_board.game_state
      @white_counter_two += 1
    else
      @white_counter_two = 0
      @last_white_game_state = @chess_board.game_state.map(&:dup)
    end
  end

  def update_black_repetition_counter
    if @black_modulo.zero?
      update_black_counter_one
    else
      update_black_counter_two
    end

    @black_modulo = 1 - @black_modulo
  end

  def update_black_counter_one
    if @second_last_black_game_state == @chess_board.game_state
      @black_counter_one += 1
    else
      @black_counter_one = 0
      @second_last_black_game_state = @chess_board.game_state.map(&:dup)
    end
  end

  def update_black_counter_two
    if @last_black_game_state == @chess_board.game_state
      @black_counter_two += 1
    else
      @black_counter_two = 0
      @last_black_game_state = @chess_board.game_state.map(&:dup)
    end
  end
end

game = Game.new
game.play_game
