require_relative "../lib/determine_check_and_mate"
describe DetermineCheckAndMate do
  subject(:pretend_board) { Class.new { extend DetermineCheckAndMate } }

  context("#in_check?") do
    context "when the white king is in check" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 2]) }
      let(:black_rook) { double("black rook", type: "R", color: "b", position: [2, 2]) }
      it "returns true" do
        pretend_board.instance_variable_set(:@white_pieces, [white_king])
        pretend_board.instance_variable_set(:@black_pieces, [black_rook])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", black_rook, "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", white_king, "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        expect(pretend_board.in_check?("w")).to be true
      end
    end

    context "when the white king is not in check" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
      let(:black_bishop) { double("black bishop", type: "B", color: "b", position: [4, 2]) }

      it "returns false" do
        pretend_board.instance_variable_set(:@white_pieces, [white_king])
        pretend_board.instance_variable_set(:@black_pieces, [black_bishop])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", black_bishop, "x", "x", "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        expect(pretend_board.in_check?("w")).to be false
      end
    end

    context "when the black king is in check" do
      let(:black_king) { double("black king", type: "K", color: "b", position: [6, 3]) }
      let(:white_knight) { double("white knight", type: "N", color: "w", position: [4, 4]) }
      it "returns true" do
        pretend_board.instance_variable_set(:@black_pieces, [black_king])
        pretend_board.instance_variable_set(:@white_pieces, [white_knight])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", "x", white_knight, "x", "x", "x"],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", black_king, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        expect(pretend_board.in_check?("b")).to be true
      end
    end

    context "when the black king is not in check" do
      let(:black_king) { double("black king", type: "K", color: "b", position: [6, 3]) }
      let(:white_pawn) { double("white knight", type: "p", color: "w", position: [5, 3]) }
      it "returns false" do
        pretend_board.instance_variable_set(:@black_pieces, [black_king])
        pretend_board.instance_variable_set(:@white_pieces, [white_pawn])
        pretend_board.instance_variable_set(:@board,
                                            [%w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             %w[x x x x x x x x],
                                             ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                             ["x", "x", "x", black_king, "x", "x", "x", "x"],
                                             %w[x x x x x x x x]])
        expect(pretend_board.in_check?("b")).to be false
      end
    end
  end
end
