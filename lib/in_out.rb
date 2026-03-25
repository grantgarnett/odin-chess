# This module handles input / output for a game of chess
# on the command line, such as prompting the user or
# displaying the board.
module InOut
  def print_board(board)
    print_top

    board.each_with_index do |row, row_index|
      print_left_side_el(row_index)

      row.each do |spot|
        print spot == "x" ? "x " : piece_to_print(spot.color, spot.type)
      end

      print_right_side_el
      print "\n"
    end

    print_bottom
  end

  def piece_to_print(piece_color, piece_type)
    if piece_color == "w"
      white_piece_to_print(piece_type)
    else
      black_piece_to_print(piece_type)
    end
  end

  # takes input and returns arr:
  # [piece type, [start pos (information given)], [target loc], taking?]
  def take_move
    loop do
      print_valid_input
      print "Make your move: "
      move = gets.chomp

      move_as_arr = convert_from_algebraic(move)
      print move_as_arr
      break unless move_as_arr.nil?

      print "Invalid input. \n\n"
    end
  end

  def convert_from_algebraic(move)
    return if move.nil? || move.size == 1

    # this means a player can call a false check or
    # mate and we won't make them redo it. Will not
    # affect actual gameplay, however.
    move.slice!(-1, 1) if ["+", "#"].include?(move[-1])

    if ["0-0", "0-0-0"].include?(move)
      move
    elsif valid_move_target?(move[-2, 2])
      convert_non_castling_move(move)
    end
  end

  private

  def print_top
    print "\n\n  - - - - - - - -\n"
  end

  def print_bottom
    print "  a b c d e f g h\n\n\n"
  end

  def print_left_side_el(row_index)
    print "#{8 - row_index} "
  end

  def print_right_side_el
    print " -"
  end

  # These pieces rendered on the command line in such a way
  # that the piece colors are switched. Printing a black pawn
  # to the command line will print a white pawn. It is confusing.
  def white_piece_to_print(piece_type)
    white_pieces = {
      "p" => "♟ ",
      "R" => "♜ ",
      "N" => "♞ ",
      "B" => "♝ ",
      "Q" => "♛ ",
      "K" => "♚ "
    }

    white_pieces[piece_type]
  end

  def black_piece_to_print(piece_type)
    black_pieces = {
      "p" => "♙ ",
      "R" => "♖ ",
      "N" => "♘ ",
      "B" => "♗ ",
      "Q" => "♕ ",
      "K" => "♔ "
    }

    black_pieces[piece_type]
  end

  def print_valid_input
    print "Please provide your input using algebraic notation. \n"
    print "For more information, go to https://www.chess.com/terms/chess-notation\n\n"
  end

  def convert_non_castling_move(move)
    if move[0].ord.between?(97, 104)
      convert_pawn_move(move)
    elsif move.count("x") == 1
      convert_standard_taking(move)
    elsif move.count("x").zero?
      convert_standard_non_taking(move)
    end
  end

  def letter_to_col(letter)
    (letter.ord - 49).chr.to_i
  end

  def number_to_row(number)
    7 - (number.to_i - 1)
  end

  def valid_move_target?(target)
    valid_col?(target[0]) && valid_row?(target[1])
  end

  def valid_col?(letter)
    letter.ord.between?(97, 104)
  end

  def valid_row?(number)
    number.ord.between?(48, 56)
  end

  def convert_pawn_move(move)
    if move.count("x") == 1 && move.size == 4 && valid_col?(move[0])
      [convert_valid_pawn_move(move), true].flatten(1)
    elsif move.count("x").zero? && move.size == 2
      [convert_valid_pawn_move(move), false].flatten(1)
    end
  end

  def convert_valid_pawn_move(move)
    ["p", [nil, letter_to_col(move[0])],
     [number_to_row(move[-1]), letter_to_col(move[-2])]]
  end

  def convert_standard_taking(move)
    return unless %w[R N B Q K].include?(move[0])

    case move.size
    when 4 then [move[0], [nil, nil], convert_move_target(move), true]
    when 5 then convert_taking_with_row_or_col(move)
    when 6
      if valid_move_target?(move[1, 2])
        [move[0], [number_to_row(move[2]), letter_to_col(move[1])],
         convert_move_target(move), true]
      end
    end
  end

  def convert_standard_non_taking(move)
    return unless %w[R N B Q K].include?(move[0])

    case move.size
    when 3 then [move[0], [nil, nil], convert_move_target(move), false]
    when 4 then convert_non_taking_with_row_or_col(move)
    when 5
      if valid_move_target?(move[1, 2])
        [move[0], [number_to_row(move[2]), letter_to_col(move[1])],
         convert_move_target(move), false]
      end
    end
  end

  # player may need to provide positional information of
  # either the row or column of the concerned piece in order
  # to be sufficiently precise.
  def convert_non_taking_with_row_or_col(move)
    if valid_col?(move[1])
      [move[0], [nil, letter_to_col(move[1])], convert_move_target(move),
       false]
    elsif valid_row?(move[1])
      [move[0], [number_to_row(move[1]), nil], convert_move_target(move), false]
    end
  end

  def convert_taking_with_row_or_col(move)
    if valid_col?(move[1])
      [move[0], [nil, letter_to_col(move[1])], convert_move_target(move), true]
    elsif valid_row?(move[1])
      [move[0], [number_to_row(move[1]), nil], convert_move_target(move), true]
    end
  end

  def convert_move_target(move)
    [number_to_row(move[-1]), letter_to_col(move[-2])]
  end
end
