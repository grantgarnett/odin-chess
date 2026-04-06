require_relative "../lib/check_defense"
require_relative "../lib/taking_moves"
require_relative "../lib/non_taking_moves"
require_relative "../lib/board"

describe CheckDefense do
  let(:board) { Board.new }
  subject(:check_defense) { CheckDefense.new(TakingMoves.new(board), NonTakingMoves.new(board)) }

  context("#check_defense") do
    before do
      allow(check_defense.non_taking).to receive(:find_king)
      allow(check_defense).to receive(:find_checking_pieces)
      allow(check_defense).to receive(:defending_king_moves)
    end

    it "sends a message to find the king" do
      allow(check_defense).to receive(:find_checking_pieces).and_return(%w[dummy_val1 dummy_val2])
      allow(check_defense).to receive(:defending_king_moves).and_return([])

      check_defense.check_defense("w")
      expect(check_defense.non_taking).to have_received(:find_king).with("w")
    end
  end

  context("#find_checking_pieces") do
    let(:king_in_check) { double("king", position: [0, 0]) }

    before do
      allow(check_defense.taking).to receive(:taking_moves).and_return([[0, 0]], [[0, 1]], [[0, 0]])
    end

    it "sends a message to calculate taking moves for each piece on the enemy team" do
      check_defense.find_checking_pieces(king_in_check, %w[piece1 piece2 piece3])
      expect(check_defense.taking).to have_received(:taking_moves).exactly(3).times
    end

    it "returns an array of the pieces whose taking moves include the king's position" do
      val = check_defense.find_checking_pieces(king_in_check, %w[piece1 piece2 piece3])
      expect(val).to eq(%w[piece1 piece3])
    end
  end

  context("#find_blocking_squares") do
    let(:king_in_check) { double("king", position: [0, 0]) }
    let(:checking_piece) { double("piece", position: [1, 1]) }

    before do
      allow(check_defense).to receive(:convert_to_dir).and_return(1)
      allow(check_defense.non_taking).to receive(:non_taking_rec)
    end

    it "sends a message to find the blocking squares" do
      check_defense.find_blocking_squares(king_in_check, checking_piece)
      expect(check_defense.non_taking).to have_received(:non_taking_rec)
    end
  end

  context("#in_check?") do
    context "when the white king is in check" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 2]) }
      let(:black_rook) { double("black rook", type: "R", color: "b", position: [2, 2]) }
      it "returns true" do
        check_defense.board.instance_variable_set(:@white_pieces, [white_king])
        check_defense.board.instance_variable_set(:@black_pieces, [black_rook])
        check_defense.board.instance_variable_set(:@game_state,
                                                  [%w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", black_rook, "x", "x", "x", "x", "x"],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", white_king, "x", "x", "x", "x", "x"],
                                                   %w[x x x x x x x x]])
        expect(check_defense.in_check?("w")).to be true
      end
    end

    context "when the white king is not in check" do
      let(:white_king) { double("white king", type: "K", color: "w", position: [6, 3]) }
      let(:black_bishop) { double("black bishop", type: "B", color: "b", position: [4, 2]) }

      it "returns false" do
        check_defense.board.instance_variable_set(:@white_pieces, [white_king])
        check_defense.board.instance_variable_set(:@black_pieces, [black_bishop])
        check_defense.board.instance_variable_set(:@game_state,
                                                  [%w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", black_bishop, "x", "x", "x", "x", "x"],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", white_king, "x", "x", "x", "x"],
                                                   %w[x x x x x x x x]])
        expect(check_defense.in_check?("w")).to be false
      end
    end

    context "when the black king is in check" do
      let(:black_king) { double("black king", type: "K", color: "b", position: [6, 3]) }
      let(:white_knight) { double("white knight", type: "N", color: "w", position: [4, 4]) }
      it "returns true" do
        check_defense.board.instance_variable_set(:@black_pieces, [black_king])
        check_defense.board.instance_variable_set(:@white_pieces, [white_knight])
        check_defense.board.instance_variable_set(:@game_state,
                                                  [%w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", "x", white_knight, "x", "x", "x"],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", black_king, "x", "x", "x", "x"],
                                                   %w[x x x x x x x x]])
        expect(check_defense.in_check?("b")).to be true
      end
    end

    context "when the black king is not in check" do
      let(:black_king) { double("black king", type: "K", color: "b", position: [6, 3]) }
      let(:white_pawn) { double("white knight", type: "p", color: "w", position: [5, 3]) }
      it "returns false" do
        check_defense.board.instance_variable_set(:@black_pieces, [black_king])
        check_defense.board.instance_variable_set(:@white_pieces, [white_pawn])
        check_defense.board.instance_variable_set(:@game_state,
                                                  [%w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                                   ["x", "x", "x", black_king, "x", "x", "x", "x"],
                                                   %w[x x x x x x x x]])
        expect(check_defense.in_check?("b")).to be false
      end
    end
  end
end
