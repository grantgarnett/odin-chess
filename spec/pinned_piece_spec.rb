require_relative "../lib/pinned_piece"
require_relative "../lib/taking_moves"
require_relative "../lib/non_taking_moves"
require_relative "../lib/board"

describe PinnedPiece do
  let(:board) { Board.new }
  subject(:pinned_piece_calc) { described_class.new(TakingMoves.new(board), NonTakingMoves.new(board)) }

  context "when a piece is pinned along the main diagonal" do
    let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
    let(:pinned_piece) { double("white piece", type: "?", color: "w", position: [5, 2]) }
    let(:pinning_queen) { double("black queen", type: "Q", color: "b", position: [3, 0]) }

    before do
      pinned_piece_calc.board.instance_variable_set(:@white_pieces, [white_king, pinned_piece])
      pinned_piece_calc.board.instance_variable_set(:@black_pieces, [pinning_queen])
      pinned_piece_calc.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     [pinning_queen, "x", "x", "x", "x", "x", "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", pinned_piece, "x", "x", "x", "x", "x"],
                                                     ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])
    end

    it "#pinned_piece? returns true" do
      expect(pinned_piece_calc.pinned_piece?(pinned_piece)).to be true
    end

    it "#valid_moves_under_pin returns the correct set of moves" do
      expect(pinned_piece_calc.valid_moves_under_pin(pinned_piece)).to contain_exactly(
        [3, 0], [4, 1]
      )
    end
  end

  context "when a piece is pinned along the minor diagonal" do
    let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
    let(:pinned_piece) { double("white piece", type: "?", color: "w", position: [4, 5]) }
    let(:pinning_bishop) { double("black bishop", type: "B", color: "b", position: [2, 7]) }

    before do
      pinned_piece_calc.board.instance_variable_set(:@white_pieces, [white_king, pinned_piece])
      pinned_piece_calc.board.instance_variable_set(:@black_pieces, [pinning_bishop])
      pinned_piece_calc.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", "x", pinning_bishop],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", pinned_piece, "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])
    end

    it "#pinned_piece returns true" do
      expect(pinned_piece_calc.pinned_piece?(pinned_piece)).to be true
    end

    it "#valid_moves_under_pin returns the correct set of moves" do
      expect(pinned_piece_calc.valid_moves_under_pin(pinned_piece)).to contain_exactly(
        [2, 7], [3, 6], [5, 4]
      )
    end
  end

  context "when a piece is pinned along a row" do
    let(:black_king) { double("black king", type: "K", color: "b", position: [2, 0]) }
    let(:pinned_piece) { double("black piece", type: "?", color: "b", position: [2, 2]) }
    let(:pinning_rook) { double("white rook", type: "R", color: "w", position: [2, 7]) }

    before do
      pinned_piece_calc.board.instance_variable_set(:@black_pieces, [black_king, pinned_piece])
      pinned_piece_calc.board.instance_variable_set(:@white_pieces, [pinning_rook])
      pinned_piece_calc.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     [black_king, "x", pinned_piece, "x", "x", "x", "x", pinning_rook],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x]])
    end

    it "#pinned_piece returns true" do
      expect(pinned_piece_calc.pinned_piece?(pinned_piece)).to be true
    end
    it "#valid_moves_under_pin returns the correct set of moves" do
      expect(pinned_piece_calc.valid_moves_under_pin(pinned_piece)).to contain_exactly(
        [2, 1], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7]
      )
    end
  end

  context "when a piece is pinned along a column" do
    let(:white_king) { double("white king", type: "K", color: "w", position: [6, 7]) }
    let(:pinned_piece) { double("white piece", type: "?", color: "w", position: [4, 7]) }
    let(:pinning_queen) { double("black queen", type: "Q", color: "b", position: [2, 7]) }

    before do
      pinned_piece_calc.board.instance_variable_set(:@white_pieces, [white_king, pinned_piece])
      pinned_piece_calc.board.instance_variable_set(:@black_pieces, [pinning_queen])
      pinned_piece_calc.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", "x", pinning_queen],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", "x", pinned_piece],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", "x", white_king],
                                                     %w[x x x x x x x x]])
    end

    it "#pinned_piece returns true" do
      expect(pinned_piece_calc.pinned_piece?(pinned_piece)).to be true
    end

    it "#valid_moves_under_pin returns the correct set of moves" do
      expect(pinned_piece_calc.valid_moves_under_pin(pinned_piece)).to contain_exactly(
        [2, 7], [3, 7], [5, 7]
      )
    end
  end

  context "when a piece is not pinned" do
    let(:black_king) { double("black king", type: "K", color: "b", position: [6, 3]) }
    let(:not_pinned_piece) { double("black piece", type: "?", color: "b", position: [4, 5]) }
    let(:not_pinning_rook) { double("white rook", type: "R", color: "w", position: [3, 6]) }
    let(:not_pinning_bishop) { double("white bishop", type: "B", color: "w", position: [3, 7]) }

    it "#pinned_piece returns false" do
      pinned_piece_calc.board.instance_variable_set(:@black_pieces, [black_king, not_pinned_piece])
      pinned_piece_calc.board.instance_variable_set(:@white_pieces, [not_pinning_rook, not_pinning_bishop])
      pinned_piece_calc.board.instance_variable_set(:@game_state,
                                                    [%w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", "x", "x", "x", not_pinning_rook, not_pinning_bishop],
                                                     ["x", "x", "x", "x", "x", not_pinned_piece, "x", "x"],
                                                     %w[x x x x x x x x],
                                                     ["x", "x", "x", black_king, "x", "x", "x", "x"],
                                                     %w[x x x x x x x x]])

      expect(pinned_piece_calc.pinned_piece?(not_pinned_piece)).to be false
    end
  end
end
