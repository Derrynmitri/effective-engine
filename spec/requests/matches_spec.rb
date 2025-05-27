require 'rails_helper'

RSpec.describe "Matches", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:player_user) { create(:user, :player) }
  let(:white_player) { create(:player) }
  let(:black_player) { create(:player) }
  let(:match) { create(:match, white_player: white_player, black_player: black_player) }

  describe "GET /matches" do
    it "returns http success" do
      get matches_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /matches/:id" do
    it "shows a match" do
      get match_path(match)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(white_player.full_name)
      expect(response.body).to include(black_player.full_name)
    end
  end

  describe "POST /matches" do
    before { sign_in admin }
    let(:valid_params) do
      {
        match: {
          white_player_id: white_player.id,
          black_player_id: black_player.id,
          status: :pending,
          played_at: Time.current
        }
      }
    end
    it "creates a new match" do
      expect {
        post matches_path, params: valid_params
      }.to change(Match, :count).by(1)
      expect(response).to redirect_to(match_path(Match.last))
      follow_redirect!
      expect(flash[:notice]).to eq('Match was successfully created.')
    end
  end

  describe "PATCH /matches/:id" do
    before { sign_in admin }
    let(:new_status) { :completed }
    it "updates a match" do
      patch match_path(match), params: { match: { status: new_status } }
      expect(response).to redirect_to(match_path(match))
      follow_redirect!
      expect(response.body).to include("Match was successfully updated.")
    end
  end

  describe "DELETE /matches/:id" do
    before { sign_in admin; match }
    it "destroys the match" do
      expect {
        delete match_path(match)
      }.to change(Match, :count).by(-1)
      expect(response).to redirect_to(matches_path)
      follow_redirect!
      expect(flash[:notice]).to eq('Match was successfully destroyed.')
    end
  end

  describe "player permissions for creating and updating matches" do
    let(:player) { create(:player, user: player_user) }
    let(:other_player) { create(:player) }
    let(:player_match_params) do
      {
        match: {
          white_player_id: player.id,
          black_player_id: other_player.id,
          status: :pending,
          played_at: Time.current
        }
      }
    end
    let(:not_involved_match_params) do
      {
        match: {
          white_player_id: create(:player).id,
          black_player_id: other_player.id,
          status: :pending,
          played_at: Time.current
        }
      }
    end

    before { sign_in player_user }

    it "allows player to create a match if they are white or black player" do
      expect {
        post matches_path, params: player_match_params
      }.to change(Match, :count).by(1)
      expect(response).to redirect_to(match_path(Match.last))
    end

    it "does not allow player to create a match if they are not involved" do
      expect {
        post matches_path, params: not_involved_match_params
      }.not_to change(Match, :count)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to eq('You are not authorised to perform this action.')
    end

    it "allows player to update a match if they are white or black player" do
      match = create(:match, white_player: player, black_player: other_player)
      patch match_path(match), params: { match: { status: :completed } }
      expect(response).to redirect_to(match_path(match))
      follow_redirect!
      expect(response.body).to include("Match was successfully updated.")
    end

    it "does not allow player to update a match if they are not involved" do
      match = create(:match, white_player: create(:player), black_player: other_player)
      patch match_path(match), params: { match: { status: :completed } }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to eq('You are not authorised to perform this action.')
    end
  end
end
