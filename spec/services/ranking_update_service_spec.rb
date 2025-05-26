require 'rails_helper'

describe RankingUpdateService do
  let!(:player1) { create(:player, ranking: 1) }
  let!(:player2) { create(:player, ranking: 2) }
  let!(:player3) { create(:player, ranking: 3) }
  let!(:player4) { create(:player, ranking: 4) }

  let(:match) { create(:match, white_player: player1, black_player: player3) }

  describe 'validations' do
    it 'raises error if match_result is nil' do
      expect { described_class.call(nil) }.to raise_error(RankingUpdateService::InvalidMatchResultError)
    end

    it 'raises error if match is nil' do
      match_result = double('MatchResult', match: nil)
      expect { described_class.call(match_result) }.to raise_error(RankingUpdateService::InvalidMatchResultError)
    end

    it 'raises error if draw and players missing' do
      match_result = double('MatchResult', match: match, draw?: true)
      allow(match).to receive(:white_player).and_return(nil)
      allow(match).to receive(:black_player).and_return(nil)
      expect { described_class.call(match_result) }.to raise_error(RankingUpdateService::InvalidMatchResultError)
    end

    it 'raises error if not draw and winner/loser missing' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: nil, loser_id: nil)
      expect { described_class.call(match_result) }.to raise_error(RankingUpdateService::InvalidMatchResultError)
    end
  end

  describe 'draw result' do
    it 'does not change rankings for adjacent players' do
      match = create(:match, white_player: player1, black_player: player2)
      match_result = double('MatchResult', match: match, draw?: true)
      expect {
        described_class.call(match_result)
      }.not_to change { [ player1.reload.ranking, player2.reload.ranking ] }
    end

    it 'moves lower-ranked player up for non-adjacent rankings' do
      match = create(:match, white_player: player1, black_player: player3)
      match_result = double('MatchResult', match: match, draw?: true)
      expect {
        described_class.call(match_result)
      }.to change { player3.reload.ranking }.from(3).to(2)
    end
  end

  describe 'win/loss result' do
    it 'does not change rankings if higher-ranked player wins' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: player1.id, loser_id: player3.id)
      expect {
        described_class.call(match_result)
      }.not_to change { [ player1.reload.ranking, player3.reload.ranking ] }
    end

    it 'moves lower-ranked winner up and loser down' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: player4.id, loser_id: player1.id)
      expect {
        described_class.call(match_result)
      }.to change { player4.reload.ranking }.from(4).to(3)
         .and change { player1.reload.ranking }.from(1).to(2)
    end

    it 'moves lower-ranked winner up and keeps loser in place for two rank difference' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: player3.id, loser_id: player1.id)
      expect {
        described_class.call(match_result)
      }.to change { player3.reload.ranking }.from(3).to(2)
        .and change { player1.reload.ranking }.by(0)
    end

    it 'swaps ranks when lower-ranked winner is adjacent to loser' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: player2.id, loser_id: player1.id)
      expect {
        described_class.call(match_result)
      }.to change { player2.reload.ranking }.from(2).to(1)
        .and change { player1.reload.ranking }.from(1).to(2)
    end
  end

  describe 'transactionality' do
    it 'rolls back all changes if an update fails' do
      match_result = double('MatchResult', match: match, draw?: false, winner_id: player3.id, loser_id: player1.id)
      allow_any_instance_of(Player).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      expect {
        begin
          described_class.call(match_result)
        rescue ActiveRecord::RecordInvalid
        end
      }.not_to change { [ player1.reload.ranking, player3.reload.ranking ] }
    end
  end
end
