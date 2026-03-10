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
end
