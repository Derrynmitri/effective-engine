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

    context "when a ranking is not provided" do
      it "is not valid" do
        player = Player.new(name: "Test", surname: "Player", birthday: "1992/01/13", user: user1, ranking: nil)
        expect(player).not_to be_valid
        expect(player.errors[:ranking]).to include("can't be blank")
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
end
