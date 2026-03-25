require_relative "../lib/board"

describe ValidateMoves do
  subject(:pretend_board) { Class.new { extend ValidateMoves } }

  describe "#non_taking_moves" do
    context "when given a pawn that has not moved, and a piece is in the way" do
      let(:starting_pawn) { double("pawn", type: "p", color: "w", position: [6, 6], move_by_two: true) }
      let(:piece_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", "x", "x", piece_in_way, "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", "x", "x", starting_pawn, "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(starting_pawn)
        expect(valid_moves).to eq([[5, 6]])
      end
    end

    context "when given a pawn that has not moved, and a piece is not in the way" do
      let(:starting_pawn) { double("pawn", type: "p", color: "w", position: [6, 6], move_by_two: true) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", "x", "x", starting_pawn, "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(starting_pawn)
        expect(valid_moves).to eq([[5, 6], [4, 6]])
      end
    end

    context "when given a pawn that has moved, and a piece is in the way" do
      let(:pawn) { double("pawn", type: "p", color: "w", position: [5, 3], move_by_two: false) }
      let(:piece_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", piece_in_way, "x", "x", "x", "x"],
                                             ["x", "x", "x", pawn, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(pawn)
        expect(valid_moves).to eq([])
      end
    end

    context "when given a pawn that has moved, and a piece is not in the way" do
      let(:pawn) { double("pawn", type: "p", color: "w", position: [5, 3], move_by_two: false) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", pawn, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(pawn)
        expect(valid_moves).to eq([[4, 3]])
      end
    end

    context "when given a rook" do
      let(:rook) { double("rook", type: "R", position: [3, 4]) }
      let(:piece_in_way) { double("generic piece") }
      let(:other_piece_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", rook, "x", "x", other_piece_in_way],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", piece_in_way, "x", "x", "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(rook)
        expect(valid_moves).to contain_exactly([2, 4], [1, 4], [0, 4], [4, 4],
                                               [5, 4], [3, 3], [3, 2], [3, 1],
                                               [3, 0], [3, 5], [3, 6])
      end
    end

    context "when given a bishop" do
      let(:bishop) { double("bishop", type: "B", position: [3, 1]) }
      let(:piece_in_way) { double("generic piece") }
      let(:other_piece_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [["x", "x", "x", "x", other_piece_in_way, "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", bishop, "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", piece_in_way, "x", "x", "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.non_taking_moves(bishop)
        expect(valid_moves).to contain_exactly([2, 0], [4, 2], [5, 3], [4, 0], [2, 2], [1, 3])
      end
    end

    context "when given a queen" do
      let(:queen) { double("queen", type: "Q", position: [4, 0]) }
      let(:piece_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x],
                                             [piece_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [queen, "x", "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.non_taking_moves(queen)
        expect(valid_moves).to contain_exactly([3, 0], [2, 0], [5, 0], [6, 0], [7, 0], [4, 1],
                                               [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7],
                                               [5, 1], [6, 2], [7, 3], [3, 1], [2, 2], [1, 3], [0, 4])
      end
    end

    context "when given a knight" do
      let(:knight) { double("knight", type: "N", position: [4, 2]) }
      let(:piece_in_way) { double("generic piece") }
      let(:piece_not_in_way) { double("generic piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x],
                                             [piece_not_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", knight, "x", "x", "x", "x", "x"],
                                             [piece_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.non_taking_moves(knight)
        expect(valid_moves).to contain_exactly([2, 3], [3, 4], [5, 4], [6, 3], [6, 1], [3, 0], [2, 1])
      end
    end

    context "when given a king, and no checks are in the way" do
      let(:king) { double("king", type: "K", color: "w", position: [7, 4]) }
      let(:piece_in_way) { double("same colored piece") }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", piece_in_way, "x", "x", "x", "x"],
                                             ["x", "x", "x", "x", king, "x", "x", "x"]])

        allow(pretend_board).to receive(:invalid_non_taking_king_moves).and_return([])
        valid_moves = pretend_board.non_taking_moves(king)
        expect(valid_moves).to contain_exactly([6, 4], [6, 5], [7, 5], [7, 3])
      end
    end

    context "when given a king, and a check is in the way" do
      let(:king) { double("king", type: "K", color: "w", position: [7, 4]) }
      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", king, "x", "x", "x"]])

        allow(pretend_board).to receive(:invalid_non_taking_king_moves).and_return([[6, 3], [7, 3]])
        valid_moves = pretend_board.non_taking_moves(king)
        expect(valid_moves).to contain_exactly([6, 4], [6, 5], [7, 5])
      end
    end
  end

  describe "#taking_moves" do
    context "when given a pawn" do
      let(:white_pawn) { double("pawn", type: "p", color: "w", position: "?") }
      let(:black_pawn) { double("pawn", type: "p", color: "b", can_en_passant: "?") }
      let(:black_piece) { double("generic piece", type: "?", color: "b", position: [3, 2]) }
      let(:white_piece) { double("generic piece", color: "w", position: "?") }

      it "can take enemy pieces" do
        allow(white_pawn).to receive(:position).and_return([4, 3])
        pretend_board.instance_variable_set(:@black_pieces, [black_piece])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", black_piece, "x", "x", "x", "x", "x"],
                                             ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.taking_moves(white_pawn)
        expect(valid_moves).to contain_exactly([3, 2])
      end

      it "ignores same colored pieces" do
        allow(white_pawn).to receive(:position).and_return([4, 3])
        pretend_board.instance_variable_set(:@black_pieces, [])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", white_piece, "x", "x", "x", "x", "x"],
                                             ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(white_pawn)
        expect(valid_moves).to contain_exactly
      end

      it "can take when en passant is possible on an enemy pawn" do
        allow(white_pawn).to receive(:position).and_return([3, 4])
        allow(black_pawn).to receive(:position).and_return([3, 5])
        allow(black_pawn).to receive(:can_en_passant).and_return true
        pretend_board.instance_variable_set(:@black_pieces, [black_pawn])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", white_pawn, black_pawn, "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(white_pawn)
        expect(valid_moves).to contain_exactly([2, 5])
      end

      it "cannot take when en passant is not possible on an enemy pawn" do
        allow(white_pawn).to receive(:position).and_return([2, 4])
        allow(black_pawn).to receive(:position).and_return([2, 5])
        allow(black_pawn).to receive(:can_en_passant).and_return false
        pretend_board.instance_variable_set(:@black_pieces, [black_pawn])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", white_pawn, black_pawn, "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(white_pawn)
        expect(valid_moves).to contain_exactly
      end

      it "works oppositely with black pawns" do
        allow(black_pawn).to receive(:position).and_return([4, 3])
        allow(white_pawn).to receive(:position).and_return([4, 4])
        allow(white_piece).to receive(:position).and_return([5, 2])
        allow(white_pawn).to receive(:can_en_passant).and_return true
        pretend_board.instance_variable_set(:@black_pieces, [black_pawn])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", black_pawn, white_pawn, "x", "x", "x"],
                                             ["x", "x", white_piece, "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(black_pawn)
        expect(valid_moves).to contain_exactly([5, 2], [5, 4])
      end
    end

    context "when given a rook" do
      let(:white_rook) { double("rook", type: "R", color: "w", position: [4, 3]) }
      let(:black_piece_one) { double("generic piece", color: "b", position: [1, 3]) }
      let(:black_piece_two) { double("generic piece", color: "b", position: [4, 7]) }
      let(:white_piece) { double("generic piece", color: "w", position: [6, 3]) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", white_rook, "x", "x", "x", black_piece_two],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", white_piece, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.taking_moves(white_rook)
        expect(valid_moves).to contain_exactly([1, 3], [4, 7])
      end
    end

    context "when given a bishop" do
      let(:white_bishop) { double("bishop", type: "B", color: "w", position: [3, 5]) }
      let(:black_piece_one) { double("generic piece", color: "b", position: [1, 3]) }
      let(:black_piece_two) { double("generic piece", color: "b", position: [2, 6]) }
      let(:black_piece_three) { double("generic piece", color: "b", position: [6, 1]) }
      let(:white_piece) { double("generic piece", color: "w", position: [4, 6]) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                             black_piece_three])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                             ["x", "x", "x", "x", "x", "x", black_piece_two, "x"],
                                             ["x", "x", "x", "x", "x", white_bishop, "x", "x"],
                                             ["x", "x", "x", "x", "x", "x", white_piece, "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", black_piece_three, "x", "x", "x", "x", "x", "x"]])

        valid_moves = pretend_board.taking_moves(white_bishop)
        expect(valid_moves).to contain_exactly([1, 3], [2, 6], [7, 1])
      end
    end

    context "when given a queen" do
      let(:white_queen) { double("queen", type: "Q", color: "w", position: [4, 1]) }
      let(:black_piece_one) { double("generic piece", color: "b", position: [2, 3]) }
      let(:black_piece_two) { double("generic piece", color: "b", position: [4, 6]) }
      let(:black_piece_three) { double("generic piece", color: "b", position: [6, 3]) }
      let(:black_piece_four) { double("generic piece", color: "b", position: [7, 1]) }
      let(:white_piece) { double("generic piece", color: "w", position: [0, 1]) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                             black_piece_three, black_piece_four])
        pretend_board.instance_variable_set(:@board,
                                            [["x", white_piece, "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", white_queen, "x", "x", "x", "x", black_piece_two, "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", black_piece_three, "x", "x", "x", "x"],
                                             ["x", black_piece_four, "x", "x", "x", "x", "x", "x"]])

        valid_moves = pretend_board.taking_moves(white_queen)
        expect(valid_moves).to contain_exactly([2, 3], [4, 6], [6, 3], [7, 1])
      end
    end

    context "when given a knight" do
      let(:white_knight) { double("knight", type: "N", color: "w", position: [5, 1]) }
      let(:black_piece_one) { double("generic piece", color: "b", position: [3, 2]) }
      let(:black_piece_two) { double("generic piece", color: "b", position: [3, 3]) }
      let(:black_piece_three) { double("generic piece", color: "b", position: [6, 3]) }

      it "returns the correct set of moves" do
        pretend_board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                             black_piece_three])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", black_piece_one, black_piece_two, "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", white_knight, "x", "x", "x", "x", "x", "x"],
                                             ["x", "x", "x", black_piece_three, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])

        valid_moves = pretend_board.taking_moves(white_knight)
        expect(valid_moves).to contain_exactly([3, 2], [6, 3])
      end
    end

    context "when given a king, and a piece is unprotected" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
      let(:black_king) { double("black king", type: "K", color: "b", position: [1, 1]) }
      let(:black_pawn) { double("black pawn", type: "p", color: "b", position: [5, 3]) }
      let(:black_rook) { double("black rook", type: "R", color: "b", position: [3, 6]) }

      it "returns the correct set of moves" do
        allow(black_rook).to receive(:color=)
        allow(black_rook).to receive(:color).and_return("w").once

        pretend_board.instance_variable_set(:@black_pieces, [black_king, black_pawn, black_rook])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             ["x", black_king, "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", "x", "x", black_rook, "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                             ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(white_king)
        expect(valid_moves).to contain_exactly([5, 3])
      end
    end

    context "when given a king, and a piece is protected" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
      let(:black_king) { double("black king", type: "K", color: "b", position: "?") }
      let(:black_pawn) { double("black pawn", type: "p", color: "b", position: [5, 3]) }
      let(:black_bishop) { double("black bishop", type: "B", color: "b", position: [2, 5]) }
      let(:black_rook) { double("black rook", type: "R", color: "b", position: [5, 2]) }

      context "when protected by a king" do
        it "returns the correct set of moves" do
          allow(black_king).to receive(:position).and_return([4, 2])

          pretend_board.instance_variable_set(:@black_pieces, [black_king, black_pawn])
          pretend_board.instance_variable_set(:@board,
                                              [%w[x x x x x x x x],
                                               %w[x x x x x x x x],
                                               %w[x x x x x x x x],
                                               %w[x x x x x x x x],
                                               ["x", "x", black_king, "x", "x", "x", "x", "x"],
                                               ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                               ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                               %w[x x x x x x x x]])
          valid_moves = pretend_board.taking_moves(white_king)
          expect(valid_moves).to contain_exactly
        end
      end

      context "when protected by another piece" do
        it "returns the correct set of moves" do
          allow(black_king).to receive(:position).and_return([2, 1])
          allow(black_rook).to receive(:color=)
          allow(black_rook).to receive(:color).and_return("w").once
          allow(black_rook).to receive(:color).and_return("b")
          allow(black_bishop).to receive(:color=)
          allow(black_bishop).to receive(:color).and_return("w").once

          pretend_board.instance_variable_set(:@black_pieces, [black_pawn, black_bishop, black_king])
          pretend_board.instance_variable_set(:@board,
                                              [%w[x x x x x x x x],
                                               %w[x x x x x x x x],
                                               ["x", black_king, "x", "x", "x", black_bishop, "x", "x"],
                                               %w[x x x x x x x x],
                                               %w[x x x x x x x x],
                                               ["x", "x", black_rook, "x", "x", "x", "x", "x"],
                                               ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                               %w[x x x x x x x x]])
          valid_moves = pretend_board.taking_moves(white_king)
          expect(valid_moves).to contain_exactly
        end
      end
    end

    context "when given a king, in the generic case" do
      let(:black_king) { double("black king", type: "K", color: "b", position: [2, 1]) }
      let(:white_pawn) { double("white pawn", type: "p", color: "w", position: [1, 0]) }
      let(:white_knight) { double("white rook", type: "N", color: "w", position: [3, 1]) }
      let(:white_rook) { double("white rook", type: "R", color: "w", position: [2, 2]) }
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }

      it "returns the correct set of moves" do
        allow(white_knight).to receive(:color).and_return("w", "b", "w")
        allow(white_knight).to receive(:color=)
        allow(white_rook).to receive(:color).and_return("w", "b", "w")
        allow(white_rook).to receive(:color=)

        pretend_board.instance_variable_set(:@white_pieces, [white_pawn, white_king, white_knight, white_rook])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             [white_pawn, "x", "x", "x", "x", "x", "x", "x"],
                                             ["x", black_king, white_rook, "x", "x", "x", "x", "x"],
                                             ["x", white_knight, "x", "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        valid_moves = pretend_board.taking_moves(black_king)
        expect(valid_moves).to contain_exactly([2, 2], [3, 1])
      end
    end
  end

  context("#can_castle?") do
    let(:black_king) { double("black king", type: "K", color: "b", position: [0, 4], can_castle: "?") }
    let(:black_long_rook) { double("black rook", type: "R", color: "b", position: [0, 0], can_castle: "?") }
    let(:black_short_rook) { double("black rook", type: "R", color: "b", position: [0, 7], can_castle: "?") }
    let(:white_king) { double("white king", type: "K", color: "w", position: [7, 4], can_castle: "?") }
    let(:white_long_rook) { double("white rook", type: "R", color: "w", position: [7, 0], can_castle: "?") }
    let(:white_short_rook) { double("white rook", type: "R", color: "w", position: [7, 7], can_castle: "?") }
    let(:generic_piece) { double("generic piece", type: "?", color: "?", position: "?") }

    context("when white is short castling") do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0")).to be true
      end

      it "returns false when a piece is in-between them" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", "x", "x", white_king, generic_piece, "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return false
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0")).to be false
      end
    end

    context "when white is long castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", generic_piece, "x", white_king, "x", "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(white_king).to receive(:can_castle).and_return false
        allow(white_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(pretend_board.can_castle?("w", "0-0-0")).to be false
      end
    end

    context "when black is short castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, "x", "x", "x", black_king, "x", generic_piece, black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(black_king).to receive(:can_castle).and_return false
        allow(black_short_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0")).to be false
      end
    end

    context "when black is long castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, generic_piece, "x", "x", black_king, "x", "x", black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return false
        pretend_board.instance_variable_set(:@board,
                                            [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0-0")).to be false
      end
    end

    context "when the pieces are out of place" do
      it "returns false" do
        allow(black_king).to receive(:can_castle).and_return false
        allow(black_long_rook).to receive(:can_castle).and_return true
        pretend_board.instance_variable_set(:@board,
                                            [["x", "x", "x", "x", "x", "x", "x", black_short_rook],
                                             ["x", "x", "x", "x", black_king, "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x]])
        expect(pretend_board.can_castle?("b", "0-0")).to be false
      end
    end
  end
end
