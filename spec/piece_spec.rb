require_relative "../lib/piece"

describe Piece do
  context("when creating a pawn") do
    subject(:pawn_test) { described_class.new("w", "p", [0, 0]) }

    it "is a pawn" do
      type = pawn_test.type
      expect(type).to eq("p")
    end

    it "can move by two" do
      move_by_two = pawn_test.move_by_two
      expect(move_by_two).to be true
    end

    it "cannot be taken by en passant" do
      en_passant = pawn_test.can_en_passant
      expect(en_passant).to be false
    end

    it "returns an error when asked if it can castle" do
      expect { pawn_test.can_castle }.to raise_error(NoMethodError)
    end
  end

  context("when creating a rook") do
    subject(:rook_test) { described_class.new("b", "R", [0, 0]) }
    it "is a rook" do
      type = rook_test.type
      expect(type).to eq("R")
    end

    it "can castle" do
      expect(rook_test.can_castle).to be true
    end

    it "raises an error when asked if it can be taken by en passant" do
      expect { rook_test.can_en_passant }.to raise_error(NoMethodError)
    end
  end

  context("when creating a king") do
    subject(:king_test) { described_class.new("b", "K", [0, 0]) }
    it "is a king" do
      type = king_test.type
      expect(type).to eq("K")
    end

    it "can castle" do
      expect(king_test.can_castle).to be true
    end

    it "raises an error when asked if it can move by two" do
      expect { king_test.move_by_two }.to raise_error(NoMethodError)
    end
  end
end
