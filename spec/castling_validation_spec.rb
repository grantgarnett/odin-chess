require_relative "../lib/board"
require_relative "../lib/castling_validation"

describe CastlingValidation do
  subject(:castling_validator) { described_class.new(Board.new) }

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
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0")).to be true
      end

      it "returns false when a piece is in-between them" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", "x", "x", white_king, generic_piece, "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return false
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0")).to be false
      end
    end

    context "when white is long castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@black_pieces, [])
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(white_king).to receive(:can_castle).and_return true
        allow(white_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", generic_piece, "x", white_king, "x", "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(white_king).to receive(:can_castle).and_return false
        allow(white_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [%w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        [white_long_rook, "x", "x", "x", white_king, "x", "x", white_short_rook]])
        expect(castling_validator.can_castle?("w", "0-0-0")).to be false
      end
    end

    context "when black is short castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, "x", "x", "x", black_king, "x", generic_piece, black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(black_king).to receive(:can_castle).and_return false
        allow(black_short_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0")).to be false
      end
    end

    context "when black is long castling" do
      it "returns true when both pieces can en passant and there's empty space between them" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@white_pieces, [])
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0-0")).to be true
      end

      it "returns false when a piece is in the way" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, generic_piece, "x", "x", black_king, "x", "x", black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0-0")).to be false
      end

      it "returns false when one of the pieces cannot en passant" do
        allow(black_king).to receive(:can_castle).and_return true
        allow(black_long_rook).to receive(:can_castle).and_return false
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [[black_long_rook, "x", "x", "x", black_king, "x", "x", black_short_rook],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0-0")).to be false
      end
    end

    context "when the pieces are out of place" do
      it "returns false" do
        allow(black_king).to receive(:can_castle).and_return false
        allow(black_long_rook).to receive(:can_castle).and_return true
        castling_validator.board.instance_variable_set(:@game_state,
                                                       [["x", "x", "x", "x", "x", "x", "x", black_short_rook],
                                                        ["x", "x", "x", "x", black_king, "x", "x", "x"],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x],
                                                        %w[x x x x x x x x]])
        expect(castling_validator.can_castle?("b", "0-0")).to be false
      end
    end
  end
end
