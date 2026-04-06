require_relative "../lib/board"
require_relative "../lib/taking_moves"

describe TakingMoves do
  subject(:taking_calculator) { described_class.new(Board.new) }

  context "when given a pawn" do
    let(:white_pawn) { double("pawn", type: "p", color: "w", position: "?") }
    let(:black_pawn) { double("pawn", type: "p", color: "b", can_en_passant: "?") }
    let(:black_piece) { double("generic piece", type: "?", color: "b", position: [3, 2]) }
    let(:white_piece) { double("generic piece", color: "w", position: "?") }

    it "can take enemy pieces" do
      allow(white_pawn).to receive(:position).and_return([4, 3])
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_piece])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", black_piece, "x", "x", "x", "x", "x"],
                                                     ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])

      valid_moves = taking_calculator.taking_moves(white_pawn)
      expect(valid_moves).to contain_exactly([3, 2])
    end

    it "ignores same colored pieces" do
      allow(white_pawn).to receive(:position).and_return([4, 3])
      taking_calculator.board.instance_variable_set(:@black_pieces, [])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", white_piece, "x", "x", "x", "x", "x"],
                                                     ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(white_pawn)
      expect(valid_moves).to contain_exactly
    end

    it "can take when en passant is possible on an enemy pawn" do
      allow(white_pawn).to receive(:position).and_return([3, 4])
      allow(black_pawn).to receive(:position).and_return([3, 5])
      allow(black_pawn).to receive(:can_en_passant).and_return true
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_pawn])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", white_pawn, black_pawn, "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(white_pawn)
      expect(valid_moves).to contain_exactly([2, 5])
    end

    it "cannot take when en passant is not possible on an enemy pawn" do
      allow(white_pawn).to receive(:position).and_return([2, 4])
      allow(black_pawn).to receive(:position).and_return([2, 5])
      allow(black_pawn).to receive(:can_en_passant).and_return false
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_pawn])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", white_pawn, black_pawn, "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(white_pawn)
      expect(valid_moves).to contain_exactly
    end

    it "works oppositely with black pawns" do
      allow(black_pawn).to receive(:position).and_return([4, 3])
      allow(white_pawn).to receive(:position).and_return([4, 4])
      allow(white_piece).to receive(:position).and_return([5, 2])
      allow(white_pawn).to receive(:can_en_passant).and_return true
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_pawn])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", black_pawn, white_pawn, "x", "x", "x"],
                                                     ["x", "x", white_piece, "x", "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(black_pawn)
      expect(valid_moves).to contain_exactly([5, 2], [5, 4])
    end
  end

  context "when given a rook" do
    let(:white_rook) { double("rook", type: "R", color: "w", position: [4, 3]) }
    let(:black_piece_one) { double("generic piece", color: "b", position: [1, 3]) }
    let(:black_piece_two) { double("generic piece", color: "b", position: [4, 7]) }
    let(:white_piece) { double("generic piece", color: "w", position: [6, 3]) }

    it "returns the correct set of moves" do
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", white_rook, "x", "x", "x", black_piece_two],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", white_piece, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])

      valid_moves = taking_calculator.taking_moves(white_rook)
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
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                                     black_piece_three])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                                     ["x", "x", "x", "x", "x", "x", black_piece_two, "x"],
                                                     ["x", "x", "x", "x", "x", white_bishop, "x", "x"],
                                                     ["x", "x", "x", "x", "x", "x", white_piece, "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", black_piece_three, "x", "x", "x", "x", "x", "x"]])

      valid_moves = taking_calculator.taking_moves(white_bishop)
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
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                                     black_piece_three, black_piece_four])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [["x", white_piece, "x", "x", "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", black_piece_one, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", white_queen, "x", "x", "x", "x", black_piece_two, "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", black_piece_three, "x", "x", "x", "x"],
                                                     ["x", black_piece_four, "x", "x", "x", "x", "x", "x"]])

      valid_moves = taking_calculator.taking_moves(white_queen)
      expect(valid_moves).to contain_exactly([2, 3], [4, 6], [6, 3], [7, 1])
    end
  end

  context "when given a knight" do
    let(:white_knight) { double("knight", type: "N", color: "w", position: [5, 1]) }
    let(:black_piece_one) { double("generic piece", color: "b", position: [3, 2]) }
    let(:black_piece_two) { double("generic piece", color: "b", position: [3, 3]) }
    let(:black_piece_three) { double("generic piece", color: "b", position: [6, 3]) }

    it "returns the correct set of moves" do
      taking_calculator.board.instance_variable_set(:@black_pieces, [black_piece_one, black_piece_two,
                                                                     black_piece_three])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", black_piece_one, black_piece_two, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", white_knight, "x", "x", "x", "x", "x", "x"],
                                                     ["x", "x", "x", black_piece_three, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])

      valid_moves = taking_calculator.taking_moves(white_knight)
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

      taking_calculator.board.instance_variable_set(:@black_pieces, [black_king, black_pawn, black_rook])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     ["x", black_king, "x", "x", "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", black_rook, "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                                     ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(white_king)
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

        taking_calculator.board.instance_variable_set(:@black_pieces, [black_king, black_pawn])
        taking_calculator.board.instance_variable_set(:@game_state,
                                                      [%w[x x x x x x x x],
                                                       %w[x x x x x x x x],
                                                       %w[x x x x x x x x],
                                                       %w[x x x x x x x x],
                                                       ["x", "x", black_king, "x", "x", "x", "x", "x"],
                                                       ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                                       ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                       %w[x x x x x x x x]])
        valid_moves = taking_calculator.taking_moves(white_king)
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

        taking_calculator.board.instance_variable_set(:@black_pieces, [black_pawn, black_bishop, black_king])
        taking_calculator.board.instance_variable_set(:@game_state,
                                                      [%w[x x x x x x x x],
                                                       %w[x x x x x x x x],
                                                       ["x", black_king, "x", "x", "x", black_bishop, "x", "x"],
                                                       %w[x x x x x x x x],
                                                       %w[x x x x x x x x],
                                                       ["x", "x", black_rook, "x", "x", "x", "x", "x"],
                                                       ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                       %w[x x x x x x x x]])
        valid_moves = taking_calculator.taking_moves(white_king)
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

      taking_calculator.board.instance_variable_set(:@white_pieces, [white_pawn, white_king, white_knight, white_rook])
      taking_calculator.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     [white_pawn, "x", "x", "x", "x", "x", "x", "x"],
                                                     ["x", black_king, white_rook, "x", "x", "x", "x", "x"],
                                                     ["x", white_knight, "x", "x", "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])
      valid_moves = taking_calculator.taking_moves(black_king)
      expect(valid_moves).to contain_exactly([2, 2], [3, 1])
    end
  end
end
