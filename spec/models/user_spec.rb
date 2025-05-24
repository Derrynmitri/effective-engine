require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'email presence' do
      it 'is invalid without an email' do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'is invalid with an empty email' do
        user = build(:user, email: '')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end
    end

    describe 'email uniqueness' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }

      it 'is invalid if the email is already taken' do
        user = build(:user, email: 'test@example.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('has already been taken')
      end

      it 'is valid with a unique email' do
        user = build(:user, email: 'new_unique_email@example.com')
        expect(user).to be_valid
      end
    end
  end

  describe 'roles' do
    let(:user) { create(:user) }

    describe 'default role' do
      it 'assigns player role by default' do
        expect(user.role).to eq('player')
        expect(user.player?).to be true
      end
    end

    describe 'role assignment' do
      it 'can be assigned admin role' do
        user.admin!
        expect(user.admin?).to be true
        expect(user.player?).to be false
      end

      it 'can be assigned referee role' do
        user.referee!
        expect(user.referee?).to be true
        expect(user.player?).to be false
      end

      it 'can check multiple roles' do
        admin = create(:user, role: :admin)
        referee = create(:user, role: :referee)
        player = create(:user, role: :player)

        expect(User.admin).to include(admin)
        expect(User.referee).to include(referee)
        expect(User.player).to include(player)
      end
    end

    describe 'role queries' do
      let!(:admin) { create(:user, role: :admin) }
      let!(:referee) { create(:user, role: :referee) }
      let!(:player) { create(:user, role: :player) }

      it 'returns users by role' do
        expect(User.admin.count).to eq(1)
        expect(User.referee.count).to eq(1)
        expect(User.player.count).to eq(1)
      end
    end
  end

  describe 'role helper methods' do
    it 'provides boolean methods for each role' do
      admin = create(:user, role: :admin)
      referee = create(:user, role: :referee)
      player = create(:user, role: :player)

      expect(admin.admin?).to be true
      expect(admin.referee?).to be false
      expect(admin.player?).to be false

      expect(referee.referee?).to be true
      expect(referee.admin?).to be false
      expect(referee.player?).to be false

      expect(player.player?).to be true
      expect(player.admin?).to be false
      expect(player.referee?).to be false
    end
  end
end
