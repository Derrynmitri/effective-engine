require 'rails_helper'

RSpec.describe MatchResult, type: :model do
  describe 'associations' do
    let(:match) { create(:match) }
    let(:winner) { create(:player) }
    let(:loser) { create(:player) }

    it 'belongs to a match' do
      match_result = build(:match_result, match: match)
      expect(match_result.match).to eq(match)
      expect(match_result.match).to be_a(Match)
    end

    it 'belongs to a winner' do
      match_result = build(:match_result, winner: winner)
      expect(match_result.winner).to eq(winner)
      expect(match_result.winner).to be_a(Player)
    end

    it 'belongs to a loser' do
      match_result = build(:match_result, loser: loser)
      expect(match_result.loser).to eq(loser)
      expect(match_result.loser).to be_a(Player)
    end
  end

  describe 'validations' do
    let(:match) { create(:match) }
    let(:winner) { create(:player) }
    let(:loser) { create(:player) }
    subject(:match_result) { build(:match_result, match: match, winner: winner, loser: loser) }

    it 'is valid with a match, winner, and loser' do
      expect(match_result).to be_valid
    end

    it 'is invalid without a match' do
      match_result.match = nil
      expect(match_result).not_to be_valid
      expect(match_result.errors[:match]).to include("must exist")
    end
  end

  describe 'draw trait' do
    it 'can be created with the draw trait' do
      match_result = create(:match_result, :draw)
      expect(match_result.draw).to be true
    end

    it 'is not a draw by default' do
      match_result = create(:match_result)
      expect(match_result.draw).to be false
    end
  end
end
