require_relative "../lib/board"

describe Board do
  context("when initialized") do
    subject(:board_test) { described_class.new }

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
end
