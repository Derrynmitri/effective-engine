require 'rails_helper'

RSpec.describe "MatchResults", type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:white_player) { create(:player) }
  let!(:black_player) { create(:player) }
  let!(:match) { create(:match, white_player: white_player, black_player: black_player) }
  let!(:match_result) { create(:match_result, match: match) }

  describe "GET /match_results/:id" do
    it "shows the match result" do
      get match_result_path(match_result)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /match_results/new" do
    before { sign_in admin }
    it "renders the new template" do
      get new_match_result_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /match_results" do
    before { sign_in admin }
    let(:valid_params) do
      {
        match_result: {
          match_id: match.id,
          winner_id: white_player.id,
          loser_id: black_player.id,
          draw: false
        }
      }
    end
    let(:draw_params) do
      {
        match_result: {
          match_id: match.id,
          draw: true
        }
      }
    end
    it "creates a match result with valid params" do
      expect {
        post match_results_path, params: valid_params
      }.to change(MatchResult, :count).by(1)
      expect(response).to redirect_to(match_result_path(MatchResult.last))
    end
    it "creates a draw match result" do
      expect {
        post match_results_path, params: draw_params
      }.to change(MatchResult, :count).by(1)
      expect(MatchResult.last.draw).to be true
    end
    it "renders new on invalid params" do
      post match_results_path, params: { match_result: { match_id: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "updates the match status to completed when a match_result is created" do
      post match_results_path, params: valid_params
      match.reload
      expect(match.status).to eq("completed")
    end
  end

  describe "GET /match_results/:id/edit" do
    before { sign_in admin }
    it "renders the edit template" do
      get edit_match_result_path(match_result)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /match_results/:id" do
    before { sign_in admin }
    with_versioning do
      it "updates the match result with valid params" do
        patch match_result_path(match_result), params: { match_result: { winner_id: black_player.id, loser_id: white_player.id, draw: false } }
        expect(response).to redirect_to(match_result_path(match_result))
        match_result.reload
        expect(match_result.winner_id).to eq(black_player.id)
      end
    end
    it "renders edit on invalid params" do
      patch match_result_path(match_result), params: { match_result: { match_id: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "sets winner and loser to nil when updated to a draw" do
      patch match_result_path(match_result), params: { match_result: { draw: true } }
      match_result.reload
      expect(match_result.draw).to be true
      expect(match_result.winner_id).to be_nil
      expect(match_result.loser_id).to be_nil
    end
  end

  describe "DELETE /match_results/:id" do
    before { sign_in admin }
    it "destroys the match result" do
      expect {
        delete match_result_path(match_result)
      }.to change(MatchResult, :count).by(-1)
      expect(response).to redirect_to(match_results_path)
    end
  end
end
