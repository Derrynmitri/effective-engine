require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:user1) { create(:user, role: :player) }
  let(:user2) { create(:user, role: :player) }

  describe "associations" do
    it "belongs to a user" do
      player = Player.new(name: "Test", surname: "Player", birthday: "1992/01/13", ranking: 10, user: user1)
      expect(player.user).to eq(user1)
    end

    it "can access the player from the user side" do
      player = Player.create!(name: "Test", surname: "Player", birthday: "1992/01/13", ranking: 10, user: user1)
      expect(user1.reload.player).to eq(player)
    end
  end

  describe "validations" do
    context "when a user is not provided" do
      it "is not valid" do
        player = Player.new(name: "Test", surname: "Player", birthday: "1992/01/13", ranking: 10, user: nil)
        expect(player).not_to be_valid
        expect(player.errors[:user]).to include("must exist")
      end
    end

    context "when a name is not provided" do
      it "is not valid" do
        player = Player.new(ranking: 10, user: user1, name: nil, surname: "Player", birthday: "1992/01/13")
        expect(player).not_to be_valid
        expect(player.errors[:name]).to include("can't be blank")
      end
    end

    context "when a surname is not provided" do
      it "is not valid" do
        player = Player.new(ranking: 10, user: user1, name: 'Test', surname: nil, birthday: "1992/01/13")
        expect(player).not_to be_valid
        expect(player.errors[:surname]).to include("can't be blank")
      end
    end

    context "when a birthday is not provided" do
      it "is not valid" do
        player = Player.new(ranking: 10, user: user1, name: "Test", surname: "Player", birthday: nil)
        expect(player).not_to be_valid
        expect(player.errors[:birthday]).to include("can't be blank")
      end
    end

    context "when a birthday is not a date" do
      it "is not valid" do
        player = Player.new(ranking: 10, user: user1, name: "Test", surname: "Player", birthday: "not_a_date")
        expect(player).not_to be_valid
        expect(player.errors[:birthday]).to include("can't be blank")
      end
    end

    context "when a birthday is not in the past" do
      it "is not valid" do
        player = Player.new(ranking: 10, user: user1, name: "Test", surname: "Player", birthday: "2125/01/13")
        expect(player).not_to be_valid
        expect(player.errors[:birthday]).to include("must be a valid date in the past")
      end
    end

    context "when a ranking is not provided set it as the lowest rank" do
      it "is valid and assigns the lowest ranking" do
        max_ranking = Player.maximum(:ranking).to_i
        player = Player.create!(name: "Test", surname: "Player", birthday: "1992/01/13", user: user1)
        expect(player.ranking).to eq(max_ranking + 1)
      end
    end

    context "when ranking is not an integer" do
      it "is not valid" do
        player = Player.new(name: "Test", surname: "Player", birthday: "1992/01/13", ranking: "not_an_integer", user: user1)
        expect(player).not_to be_valid
        expect(player.errors[:ranking]).to include("is not a number")
      end

      it "is not valid for float numbers" do
        player = Player.new(name: "Test", surname: "Player", birthday: "1992/01/13", ranking: 10.5, user: user1)
        expect(player).not_to be_valid
        expect(player.errors[:ranking]).to include("must be an integer")
      end
    end

    context "when the ranking is not unique" do
      before do
        Player.create!(name: "Player", surname: "One", birthday: "1990/01/01", ranking: 15, user: user1)
      end

      it "is not valid" do
        duplicate_ranking_player = Player.new(name: "Player", surname: "Two", birthday: "1992/01/13", ranking: 15, user: user2)
        expect(duplicate_ranking_player).not_to be_valid
        expect(duplicate_ranking_player.errors[:ranking]).to include("has already been taken")
      end

      it "is valid with a different ranking" do
        unique_ranking_player = Player.new(name: "Player", surname: "Two", birthday: "1992/01/13", ranking: 16, user: user2)
        expect(unique_ranking_player).to be_valid
      end
    end

    context "with all valid attributes" do
      it "is valid" do
        player = Player.new(name: "Valid", surname: "Player", birthday: "1992/01/13", ranking: 11, user: user1)
        expect(player).to be_valid
      end
    end
  end

  describe 'matches' do
    let(:player1) { create(:player) }
    let(:player2) { create(:player) }
    let(:player3) { create(:player) }

    let!(:match_as_white) { create(:match, white_player: player1, black_player: player2) }
    let!(:match_as_black) { create(:match, white_player: player2, black_player: player1) }
    let!(:other_match) { create(:match, white_player: player2, black_player: player3) }

    it 'returns all matches where the player was white_player' do
      expect(player1.matches).to include(match_as_white)
    end

    it 'returns all matches where the player was black_player' do
      expect(player1.matches).to include(match_as_black)
    end

    it 'does not return matches where the player was not involved' do
      expect(player1.matches).not_to include(other_match)
    end

    it 'returns a comprehensive list of matches the player participated in' do
      expect(player1.matches.count).to eq(2)
      expect(player1.matches).to match_array([ match_as_white, match_as_black ])
    end
  end

  describe 'number_of_club_games_played' do
    let(:player) { create(:player) }
    let(:opponent) { create(:player) }

    context 'when player has no matches' do
      it 'returns 0' do
        expect(player.number_of_club_games_played).to eq(0)
      end
    end

    context 'when player has matches with different statuses' do
      before do
        create(:match, white_player: player, black_player: opponent, status: :completed)
        create(:match, white_player: opponent, black_player: player, status: :completed)
        create(:match, white_player: player, black_player: opponent, status: :pending)
        create(:match, white_player: opponent, black_player: player, status: :cancelled)
        create(:match, white_player: opponent, black_player: opponent, status: :completed)
      end

      it 'returns the count of completed matches by default' do
        expect(player.number_of_club_games_played).to eq(2)
      end

      it 'returns the count of matches matching a specific status when provided' do
        expect(player.number_of_club_games_played(game_status: :pending)).to eq(1)
        expect(player.number_of_club_games_played(game_status: :cancelled)).to eq(1)
      end

      it 'returns the count of matches matching an array of statuses' do
        expect(player.number_of_club_games_played(game_status: [ :cancelled, :completed ])).to eq(3)
      end

      it 'returns 0 if no matches match the specified status' do
        expect(player.number_of_club_games_played(game_status: :in_progress)).to eq(0)
      end
    end

    context 'when player is only white player in completed matches' do
      before do
        create_list(:match, 2, white_player: player, black_player: opponent, status: :completed)
      end
      it 'returns the correct count' do
        expect(player.number_of_club_games_played).to eq(2)
      end
    end

    context 'when player is only black player in completed matches' do
      before do
        create_list(:match, 3, white_player: opponent, black_player: player, status: :completed)
      end
      it 'returns the correct count' do
        expect(player.number_of_club_games_played).to eq(3)
      end
    end
  end
end
