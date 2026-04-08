class DrawConditions
  attr_reader :board

  def initialize(taking_calculator, non_taking_calculator) # rubocop: disable Metrics/MethodLength
    @taking = taking_calculator
    @non_taking = non_taking_calculator
    @board = @taking.board

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

  def draw?(current_player_color)
    draw_by_fifty_move_rule? ||
      draw_by_threefold_repetition? ||
      stalemate?(current_player_color)
  end

  def update_repetition_counter(current_player_color)
    if current_player_color == "w"
      update_white_repetition_counter
    else
      update_black_repetition_counter
    end
  end

  def stalemate?(color)
    team = color == "w" ? @board.white_pieces : @board.black_pieces

    if team.all? { |piece| %w[K p].include?(piece.type) }
      return team.all? do |piece|
        @taking.taking_moves(piece).empty? &&
        @non_taking.non_taking_moves(piece).empty?
      end
    end

    false
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
    @board.fifty_move_counter >= 50
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
end
