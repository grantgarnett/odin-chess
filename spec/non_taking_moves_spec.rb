require_relative "../lib/board"
require_relative "../lib/non_taking_moves"

describe NonTakingMoves do
  subject(:non_taking_calculator) { described_class.new(Board.new) }

  context "when given a pawn that has not moved, and a piece is in the way" do
    let(:starting_pawn) { double("pawn", type: "p", color: "w", position: [6, 6], move_by_two: true) }
    let(:piece_in_way) { double("generic piece") }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", "x", "x", piece_in_way, "x"],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", "x", "x", starting_pawn, "x"],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(starting_pawn)
      expect(valid_moves).to eq([[5, 6]])
    end
  end

  context "when given a pawn that has not moved, and a piece is not in the way" do
    let(:starting_pawn) { double("pawn", type: "p", color: "w", position: [6, 6], move_by_two: true) }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", "x", "x", starting_pawn, "x"],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(starting_pawn)
      expect(valid_moves).to eq([[5, 6], [4, 6]])
    end
  end

  context "when given a pawn that has moved, and a piece is in the way" do
    let(:pawn) { double("pawn", type: "p", color: "w", position: [5, 3], move_by_two: false) }
    let(:piece_in_way) { double("generic piece") }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", piece_in_way, "x", "x", "x", "x"],
                                                         ["x", "x", "x", pawn, "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(pawn)
      expect(valid_moves).to eq([])
    end
  end

  context "when given a pawn that has moved, and a piece is not in the way" do
    let(:pawn) { double("pawn", type: "p", color: "w", position: [5, 3], move_by_two: false) }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", pawn, "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(pawn)
      expect(valid_moves).to eq([[4, 3]])
    end
  end

  context "when given a rook" do
    let(:rook) { double("rook", type: "R", position: [3, 4]) }
    let(:piece_in_way) { double("generic piece") }
    let(:other_piece_in_way) { double("generic piece") }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", rook, "x", "x", other_piece_in_way],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", piece_in_way, "x", "x", "x"],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(rook)
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
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [["x", "x", "x", "x", other_piece_in_way, "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", bishop, "x", "x", "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", piece_in_way, "x", "x", "x"],
                                                         %w[x x x x x x x x]])

      valid_moves = non_taking_calculator.non_taking_moves(bishop)
      expect(valid_moves).to contain_exactly([2, 0], [4, 2], [5, 3], [4, 0], [2, 2], [1, 3])
    end
  end

  context "when given a queen" do
    let(:queen) { double("queen", type: "Q", position: [4, 0]) }
    let(:piece_in_way) { double("generic piece") }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x],
                                                         [piece_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         [queen, "x", "x", "x", "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x]])
      valid_moves = non_taking_calculator.non_taking_moves(queen)
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
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x],
                                                         [piece_not_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", knight, "x", "x", "x", "x", "x"],
                                                         [piece_in_way, "x", "x", "x", "x", "x", "x", "x"],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x]])
      valid_moves = non_taking_calculator.non_taking_moves(knight)
      expect(valid_moves).to contain_exactly([2, 3], [3, 4], [5, 4], [6, 3], [6, 1], [3, 0], [2, 1])
    end
  end

  context "when given a king, and no checks are in the way" do
    let(:king) { double("king", type: "K", color: "w", position: [7, 4]) }
    let(:piece_in_way) { double("same colored piece") }

    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", piece_in_way, "x", "x", "x", "x"],
                                                         ["x", "x", "x", "x", king, "x", "x", "x"]])

      allow(non_taking_calculator).to receive(:invalid_non_taking_king_moves).and_return([])
      valid_moves = non_taking_calculator.non_taking_moves(king)
      expect(valid_moves).to contain_exactly([6, 4], [6, 5], [7, 5], [7, 3])
    end
  end

  context "when given a king, and a check is in the way" do
    let(:king) { double("king", type: "K", color: "w", position: [7, 4]) }
    it "returns the correct set of moves" do
      non_taking_calculator.board.instance_variable_set(:@game_state,
                                                        [%w[x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         %w[x x x x x x x x],
                                                         ["x", "x", "x", "x", king, "x", "x", "x"]])

      allow(non_taking_calculator).to receive(:invalid_non_taking_king_moves).and_return([[6, 3], [7, 3]])
      valid_moves = non_taking_calculator.non_taking_moves(king)
      expect(valid_moves).to contain_exactly([6, 4], [6, 5], [7, 5])
    end
  end
end
