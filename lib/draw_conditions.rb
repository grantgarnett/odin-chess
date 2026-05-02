require_relative "basic_serializable"
require_relative "pinned_piece"

# This class evaluates whether or not the
# game is drawn
class DrawConditions # rubocop: disable Metrics/ClassLength
  include BasicSerializable

  attr_reader :board

  def initialize(taking_calculator, non_taking_calculator) # rubocop: disable Metrics/MethodLength
    @pin_calc = PinnedPiece.new(taking_calculator, non_taking_calculator)
    @board = @pin_calc.board

    @last_white_game_state = " "
    @second_last_white_game_state = " "
    @last_black_game_state = " "
    @second_last_black_game_state = " "
    @white_modulo = 0
    @black_modulo = 0
    @white_counter_one = 0
    @white_counter_two = 0
    @black_counter_one = 0
    @black_counter_two = 0

    @fifty_move_counter = 0

    @serializable = [@last_white_game_state, @second_last_white_game_state,
                     @last_black_game_state, @second_last_black_game_state,
                     @white_modulo, @black_modulo, @white_counter_one,
                     @white_counter_two, @black_counter_one,
                     @black_counter_two, @fifty_move_counter]
  end

  def draw?(current_player_color)
    draw_by_fifty_move_rule? ||
      draw_by_threefold_repetition? ||
      stalemate?(current_player_color) ||
      draw_by_insufficient_material?
  end

  def stalemate?(color)
    team = color == "w" ? @board.white_pieces : @board.black_pieces

    if team.all? { |piece| %w[K p].include?(piece.type) }
      return team.all? do |piece|
        @pin_calc.valid_piece_moves_including_pins(piece).empty?
      end
    end

    false
  end

  def update_repetition_counter(current_player_color)
    if current_player_color == "w"
      update_white_repetition_counter
    else
      update_black_repetition_counter
    end
  end

  def increment_fifty_move_counter
    @fifty_move_counter += 1
  end

  def reset_fifty_move_counter
    @fifty_move_counter = 0
  end

  def draw_by_insufficient_material?
    not_enough_pieces_to_mate? ||
      two_knights_versus_sole_king?
  end

  def serialize
    obj = {}

    instance_variables.each do |var|
      obj[var] = instance_variable_get(var) unless %i[@board
                                                      @pin_calc].include? var
    end

    JSON.dump(obj)
  end

  private

  def draw_by_threefold_repetition?
    @white_counter_one == 3 ||
      @white_counter_two == 3 ||
      @black_counter_one == 3 ||
      @black_counter_two == 3 ||
      @black_repetition_counter == 3
  end

  def draw_by_fifty_move_rule?
    @fifty_move_counter >= 50
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
    if @second_last_white_game_state == @board.game_state
      @white_counter_one += 1
    else
      @white_counter_one = 0
      @second_last_white_game_state = @board.game_state.map(&:dup)
    end
  end

  def update_white_counter_two
    if @last_white_game_state == @board.game_state
      @white_counter_two += 1
    else
      @white_counter_two = 0
      @last_white_game_state = @board.game_state.map(&:dup)
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
    if @second_last_black_game_state == @board.game_state
      @black_counter_one += 1
    else
      @black_counter_one = 0
      @second_last_black_game_state = @board.game_state.map(&:dup)
    end
  end

  def update_black_counter_two
    if @last_black_game_state == @board.game_state
      @black_counter_two += 1
    else
      @black_counter_two = 0
      @last_black_game_state = @board.game_state.map(&:dup)
    end
  end

  def not_enough_pieces_to_mate?
    not_enough_white_pieces_to_mate? &&
      not_enough_black_pieces_to_mate?
  end

  def not_enough_white_pieces_to_mate?
    @board.white_pieces.size <= 2 &&
      @board.white_pieces.all? do |piece|
        %w[N B K].include? piece.type
      end
  end

  def not_enough_black_pieces_to_mate?
    @board.black_pieces.size <= 2 &&
      @board.black_pieces.all? do |piece|
        %w[N B K].include? piece.type
      end
  end

  def two_knights_versus_sole_king?
    teams = [@board.white_pieces, @board.black_pieces]

    teams.any? { |team| team.size == 1 } &&
      teams.any? do |team|
        team.size == 3 &&
          team.count { |piece| piece.type == "N" } == 2
      end
  end
end
