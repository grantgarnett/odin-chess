require_relative "../lib/board"

describe Board do
  subject(:board_test) { described_class.new }
  context("when initialized") do
    it "puts black pieces on the top files" do
      random_black_pawn = board_test.board[1][3]
      expect(random_black_pawn.color).to eq("b")
    end

    it "puts white pieces on the bottom files" do
      random_white_pawn = board_test.board[7][5]
      expect(random_white_pawn.color).to eq("w")
    end

    it "puts empty pieces in the middle" do
      random_space = board_test.board[3][4]
      expect(random_space).to eq("x")
    end
  end

  context("#move_piece") do
    context "when moving to an empty space" do
      # this functionality is separate from move validation, so this method
      # will simply move the piece
      let(:generic_piece) { double("generic piece", type: "?", color: "?", position: [6, 3]) }

      before do
        allow(generic_piece).to receive(:position=)
        board_test.instance_variable_set(:@board,
                                         [%w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          ["x", "x", "x", generic_piece, "x", "x", "x", "x"],
                                          %w[x x x x x x x x]])
        board_test.move_piece(generic_piece, [4, 3])
      end

      it "moves the piece to the correct location" do
        expect(board_test.board[4][3]).to eq(generic_piece)
      end

      it "updates the position variable for the piece" do
        expect(generic_piece).to have_received(:position=).with([4, 3])
      end

      it "empties the space where the piece was" do
        expect(board_test.board[6][3]).to eq("x")
      end
    end

    context "when moving to an occupied space" do
      let(:generic_black_piece) { double("generic piece", type: "?", color: "b", position: [2, 2]) }
      let(:generic_white_piece) { double("generic piece", type: "?", color: "w", position: [4, 4]) }

      before do
        allow(generic_black_piece).to receive(:position=)
        board_test.instance_variable_set(:@white_pieces, [generic_white_piece])
        board_test.instance_variable_set(:@board,
                                         [%w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          ["x", "x", generic_black_piece, "x", "x", "x", "x", "x"],
                                          %w[x x x x x x x x],
                                          ["x", "x", "x", "x", generic_white_piece, "x", "x", "x"],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x],
                                          %w[x x x x x x x x]])
        board_test.move_piece(generic_black_piece, [4, 4])
      end
      it "replaces the original piece with the new one at the target location" do
        expect(board_test.board[4][4]).to eq(generic_black_piece)
      end

      it "updates the location variable for the piece" do
        expect(generic_black_piece).to have_received(:position=).with([4, 4])
      end

      it "empties the space where the piece was" do
        expect(board_test.board[2][2]).to eq("x")
      end

      it "removes the original piece from its corresponding team array" do
        piece_included = board_test.white_pieces.include?(generic_white_piece)
        expect(piece_included).to be false
      end
    end
  end
end
