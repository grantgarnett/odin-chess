require_relative "../lib/in_out"

describe InOut do
  let(:dummy_class) { Class.new { extend InOut } }

  # the command line rendering of these pieces switches
  # the colors, so that white appears as black and vice
  # versa. It is confusing.
  context("#piece_to_print") do
    it "returns the appropriate piece" do
      expect(dummy_class.piece_to_print("w", "p")).to eq("♟ ")
    end

    it "returns the appropriate piece a second time" do
      expect(dummy_class.piece_to_print("b", "N")).to eq("♘ ")
    end
  end

  # for normal moves, returns arr:
  # [piece type, [starting pos], [target loc], taking?]
  context("#convert_from_algebraic") do
    context("when castling") do
      it "returns the short castling symbol" do
        return_val = dummy_class.convert_from_algebraic("0-0")
        expect(return_val).to eq("0-0")
      end

      it "returns the long castling symbol" do
        return_val = dummy_class.convert_from_algebraic("0-0-0")
        expect(return_val).to eq("0-0-0")
      end
    end

    context("when moving a pawn") do
      it "interprets normal pawn moves correctly" do
        return_val = dummy_class.convert_from_algebraic("e5")
        expect(return_val).to eq(["p", [nil, 4], [3, 4], false])
      end

      it "interprets pawn takes correctly" do
        return_val = dummy_class.convert_from_algebraic("cxd6")
        expect(return_val).to eq(["p", [nil, 2], [2, 3], true])
      end
    end

    context("when not taking with a standard piece") do
      it "interprets moves with only piece type provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Kf5")
        expect(return_val).to eq(["K", [nil, nil], [3, 5], false])
      end

      it "interprets moves with piece type and column provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Nab7")
        expect(return_val).to eq(["N", [nil, 0], [1, 1], false])
      end

      it "interprets moves with piece type and row provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Q4g2")
        expect(return_val).to eq(["Q", [4, nil], [6, 6], false])
      end

      it "interprets moves with piece type, row, and column provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Bd1h3")
        expect(return_val).to eq(["B", [7, 3], [5, 7], false])
      end
    end

    context("when taking with a standard piece") do
      it "interprets moves with only piece type provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Nxg8")
        expect(return_val).to eq(["N", [nil, nil], [0, 6], true])
      end

      it "interprets moves with piece type and column provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Bcxd2")
        expect(return_val).to eq(["B", [nil, 2], [6, 3], true])
      end

      it "interprets moves with piece type and row provided correctly" do
        return_val = dummy_class.convert_from_algebraic("R1xe1")
        expect(return_val).to eq(["R", [7, nil], [7, 4], true])
      end

      it "interprets moves with piece type, row, and column provided correctly" do
        return_val = dummy_class.convert_from_algebraic("Qa8xf3")
        expect(return_val).to eq(["Q", [0, 0], [5, 5], true])
      end
    end

    context("when given a call for check or mate") do
      it "allows '+' symbol at end" do
        return_val = dummy_class.convert_from_algebraic("h6+")
        expect(return_val).to eq(["p", [nil, 7], [2, 7], false])
      end

      it "allows '#' symbol at end" do
        return_val = dummy_class.convert_from_algebraic("Nxb4#")
        expect(return_val).to eq(["N", [nil, nil], [4, 1], true])
      end
    end

    context("when given invalid input") do
      it "returns nil" do
        return_val = dummy_class.convert_from_algebraic("Ka9")
        expect(return_val).to be_nil
      end
    end
  end
end
