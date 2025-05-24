require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'associations' do
    let(:player1) { create(:player) }
    let(:player2) { create(:player) }

    it 'belongs to a white player' do
      match = build(:match, white_player: player1)
      expect(match.white_player).to eq(player1)
      expect(match.white_player).to be_a(Player)
    end

    it 'belongs to a black player' do
      match = build(:match, black_player: player2)
      expect(match.black_player).to eq(player2)
      expect(match.black_player).to be_a(Player)
    end

    it 'is invalid without a white_player' do
      match = build(:match, white_player: nil)
      match.valid?
      expect(match.errors[:white_player]).to include("must exist")
    end

    it 'is invalid without a black_player' do
      match = build(:match, black_player: nil)
      match.valid?
      expect(match.errors[:black_player]).to include("must exist")
    end
  end

  describe 'validations' do
    let(:player1) { create(:player) }
    let(:player2) { create(:player) }
    subject(:match) { build(:match) }

    context 'for status' do
      it 'is valid with a valid status' do
        statuses = [ :pending, :in_progress, :completed, :cancelled ]
        statuses.each do |valid_status|
          match.status = valid_status
          expect(match).to be_valid
        end
      end

      it 'defaults to pending' do
      new_match = Match.new(white_player: player1, black_player: player2)
      expect(new_match.status).to eq('pending')
      expect(new_match).to be_valid
    end

      it 'is invalid if status is nil' do
        match.status = nil
        expect(match).not_to be_valid
        expect(match.errors[:status]).to include("can't be blank")
      end
    end

    context 'for played_at' do
      it 'is valid with a played_at datetime' do
        match.played_at = Time.current
        expect(match).to be_valid
      end

      it 'is valid if played_at is nil' do
        match.played_at = nil
        expect(match).to be_valid
      end
    end
  end
end
