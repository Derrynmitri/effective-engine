require 'rails_helper'

describe 'Players', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:player_user) { create(:user, role: :player) }
  let(:player) { create(:player, user: player_user) }

  describe 'GET /players/new' do
    context 'as admin' do
      before { sign_in admin }
      it 'allows access' do
        get new_player_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as non-admin' do
      before { sign_in player_user }
      it 'redirects with alert' do
        get new_player_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(flash[:alert]).to eq('You are not authorised to perform this action.')
      end
    end
  end

  describe 'POST /players' do
    before { sign_in admin }
    let(:valid_params) do
      {
        player: {
          name: 'Test',
          surname: 'Player',
          birthday: '2000-01-01',
          ranking: 1,
          user_email: 'newplayer@example.com',
          user_password: 'password123'
        }
      }
    end
    it 'creates a new player' do
      expect {
        post players_path, params: valid_params
      }.to change(Player, :count).by(1)
      expect(response).to redirect_to(Player.last)
      follow_redirect!
      expect(flash[:notice]).to eq('Player was successfully created.')
    end
  end

  describe 'POST /players as non-admin' do
    before { sign_in player_user }
    let(:valid_params) do
      {
        player: {
          name: 'Test',
          surname: 'Player',
          birthday: '2000-01-01',
          ranking: 2,
          user_email: 'anotherplayer@example.com',
          user_password: 'password123'
        }
      }
    end
    it 'redirects with alert' do
      post players_path, params: valid_params
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to eq('You are not authorised to perform this action.')
    end
  end

  describe 'DELETE /players/:id' do
    before do
      sign_in admin
      player
    end
    it 'destroys the player' do
      expect {
        delete player_path(player)
      }.to change(Player, :count).by(-1)
      expect(response).to redirect_to(players_path)
      follow_redirect!
      expect(flash[:notice]).to eq('Player was successfully destroyed.')
    end
  end

  describe 'DELETE /players/:id as non-admin' do
    before { player }
    it 'redirects with alert' do
      sign_in player_user
      delete player_path(player)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to eq('You are not authorised to perform this action.')
    end
  end

  describe 'DELETE /players/:id for non-existent player' do
    before { sign_in admin }
    it 'redirects or shows error when player does not exist' do
      expect {
        delete player_path(999_999)
      }.not_to change(Player, :count)
      expect(response).to redirect_to(players_path).or have_http_status(:not_found)
    end
  end
end
