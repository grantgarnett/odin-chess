require_relative "../lib/draw_conditions"
require_relative "../lib/taking_moves"
require_relative "../lib/non_taking_moves"
require_relative "../lib/board"

describe DrawConditions do
  let(:board) { Board.new }
  subject(:draw_conditions) { described_class.new(TakingMoves.new(board), NonTakingMoves.new(board)) }

  context("#stalemate?") do
    let(:white_pawn) { double("pawn", type: "p", color: "w", position: [4, 3], move_by_two: false) }
    let(:white_rook) { double("white rook", type: "R", color: "w", position: "?") }
    let(:white_king) { double("white king", type: "K", color: "w", position: [2, 7]) }
    let(:black_pawn) { double("pawn", type: "p", color: "b", position: [3, 3], move_by_two: false) }
    let(:black_king) { double("black king", type: "K", color: "b", position: [0, 7]) }

    it "returns true when in stalemate" do
      allow(white_rook).to receive(:position).and_return([2, 6])
      allow(white_rook).to receive(:color=)
      allow(white_rook).to receive(:color).and_return("b").once
      allow(white_rook).to receive(:color).and_return("w")

      draw_conditions.board.instance_variable_set(:@white_pieces, [white_pawn, white_rook, white_king])
      draw_conditions.board.instance_variable_set(:@black_pieces, [black_pawn, black_king])
      draw_conditions.board.instance_variable_set(:@game_state,
                                                  [["x", "x", "x", "x", "x", "x", "x", black_king],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", "x", "x", "x", white_rook, white_king],
                                                   ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                                   ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x]])

      expect(draw_conditions.stalemate?("b")).to be true
    end

    it "returns false otherwise" do
      allow(white_rook).to receive(:position).and_return([2, 5])
      allow(white_rook).to receive(:color=)
      allow(white_rook).to receive(:color).and_return("b").once
      allow(white_rook).to receive(:color).and_return("w")

      draw_conditions.board.instance_variable_set(:@white_pieces, [white_pawn, white_rook, white_king])
      draw_conditions.board.instance_variable_set(:@black_pieces, [black_pawn, black_king])
      draw_conditions.board.instance_variable_set(:@game_state,
                                                  [["x", "x", "x", "x", "x", "x", "x", black_king],
                                                   %w[x x x x x x x x],
                                                   ["x", "x", "x", "x", "x", white_rook, "x", white_king],
                                                   ["x", "x", "x", black_pawn, "x", "x", "x", "x"],
                                                   ["x", "x", "x", white_pawn, "x", "x", "x", "x"],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x],
                                                   %w[x x x x x x x x]])

      expect(draw_conditions.stalemate?("b")).to be false
    end
  end

  context("draw_by_insufficient_material?") do
    let(:white_king) { double("king", type: "K") }
    let(:black_king) { double("king", type: "K") }
    let(:bishop) { double("bishop", type: "B") }
    let(:knight_one) { double("knight", type: "N") }
    let(:knight_two) { double("knight", type: "N") }
    let(:queen) { double("queen", type: "Q") }
    let(:pawn) { double("pawn", type: "p") }

    context("when each team has a king and one knight / bishop or less") do
      before do
        draw_conditions.board.instance_variable_set(:@white_pieces, [white_king, bishop])
        draw_conditions.board.instance_variable_set(:@black_pieces, [black_king, knight_one])
      end

      it "returns true" do
        expect(draw_conditions.draw_by_insufficient_material?).to be true
      end
    end

    context("when one team has only a king and the other has a king and two knights") do
      before do
        draw_conditions.board.instance_variable_set(:@white_pieces, [white_king])
        draw_conditions.board.instance_variable_set(:@black_pieces, [black_king, knight_one, knight_two])
      end
      it "returns true" do
        expect(draw_conditions.draw_by_insufficient_material?).to be true
      end
    end

    context("in any other case") do
      it "returns false" do
        draw_conditions.board.instance_variable_set(:@white_pieces, [white_king, bishop])
        draw_conditions.board.instance_variable_set(:@black_pieces, [black_king, knight_one, knight_two])

        expect(draw_conditions.draw_by_insufficient_material?).to be false
      end

      it "returns false again" do
        draw_conditions.board.instance_variable_set(:@white_pieces, [white_king, pawn])
        draw_conditions.board.instance_variable_set(:@black_pieces, [black_king])

        expect(draw_conditions.draw_by_insufficient_material?).to be false
      end
    end
  end
end
