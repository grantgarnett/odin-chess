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
end
