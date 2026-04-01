require_relative "../lib/check_defense"
describe CheckDefense do
  subject(:check_defense) { CheckDefense.new("board") }

  context("#check_defense") do
    before do
      allow(check_defense).to receive(:find_king)
      allow(check_defense).to receive(:find_checking_pieces)
      allow(check_defense).to receive(:defending_king_moves)
    end

    it "sends a message to find the king" do
      allow(check_defense).to receive(:find_checking_pieces).and_return(%w[dummy_val1 dummy_val2])
      allow(check_defense).to receive(:defending_king_moves).and_return([])

      check_defense.check_defense("w")
      expect(check_defense).to have_received(:find_king).with("w")
    end
  end

  context("#find_checking_pieces") do
    let(:king_in_check) { double("king", position: [0, 0]) }

    before do
      allow(check_defense).to receive(:taking_moves).and_return([[0, 0]], [[0, 1]], [[0, 0]])
    end

    it "sends a message to calculate taking moves for each piece on the enemy team" do
      check_defense.find_checking_pieces(king_in_check, %w[piece1 piece2 piece3])
      expect(check_defense).to have_received(:taking_moves).exactly(3).times
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
      allow(check_defense).to receive(:non_taking_rec)
    end

    it "sends a message to find the blocking squares" do
      check_defense.find_blocking_squares(king_in_check, checking_piece)
      expect(check_defense).to have_received(:non_taking_rec)
    end
  end
end
