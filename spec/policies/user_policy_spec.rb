require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:referee) { create(:user, role: :referee) }
  let(:player) { create(:user, role: :player) }
  let(:other_player) { create(:user, role: :player) }

  describe '#index?' do
    it 'allows admins' do
      policy = UserPolicy.new(admin, User)
      expect(policy.index?).to be true
    end

    it 'allows referees' do
      policy = UserPolicy.new(referee, User)
      expect(policy.index?).to be true
    end

    it 'denies players' do
      policy = UserPolicy.new(player, User)
      expect(policy.index?).to be false
    end
  end

  describe '#show?' do
    it 'allows everyone to view any player profile' do
      expect(UserPolicy.new(admin, player).show?).to be true
      expect(UserPolicy.new(referee, player).show?).to be true
      expect(UserPolicy.new(player, other_player).show?).to be true
      expect(UserPolicy.new(other_player, player).show?).to be true
    end
  end

  describe '#create?' do
    it 'allows only admins' do
      expect(UserPolicy.new(admin, User).create?).to be true
      expect(UserPolicy.new(referee, User).create?).to be false
      expect(UserPolicy.new(player, User).create?).to be false
    end
  end

  describe '#update?' do
    it 'allows admins to update anyone' do
      expect(UserPolicy.new(admin, player).update?).to be true
      expect(UserPolicy.new(admin, referee).update?).to be true
    end

    it 'allows users to update themselves' do
      expect(UserPolicy.new(player, player).update?).to be true
      expect(UserPolicy.new(referee, referee).update?).to be true
    end

    it 'denies users updating others' do
      expect(UserPolicy.new(player, other_player).update?).to be false
      expect(UserPolicy.new(referee, player).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'allows admins to delete others' do
      expect(UserPolicy.new(admin, player).destroy?).to be true
      expect(UserPolicy.new(admin, referee).destroy?).to be true
    end

    it 'prevents admins from deleting themselves' do
      expect(UserPolicy.new(admin, admin).destroy?).to be false
    end

    it 'denies non-admins' do
      expect(UserPolicy.new(referee, player).destroy?).to be false
      expect(UserPolicy.new(player, other_player).destroy?).to be false
      expect(UserPolicy.new(player, player).destroy?).to be false
    end
  end

  describe '#manage_roles?' do
    it 'allows only admins' do
      expect(UserPolicy.new(admin, player).manage_roles?).to be true
      expect(UserPolicy.new(referee, player).manage_roles?).to be false
      expect(UserPolicy.new(player, player).manage_roles?).to be false
    end
  end

  describe '#permitted_attributes' do
    it 'allows admins to change roles' do
      policy = UserPolicy.new(admin, player)
      expect(policy.permitted_attributes).to include(:role)
    end

    it 'prevents non-admins from changing roles' do
      policy = UserPolicy.new(player, player)
      expect(policy.permitted_attributes).not_to include(:role)

      policy = UserPolicy.new(referee, player)
      expect(policy.permitted_attributes).not_to include(:role)
    end

    it 'allows basic attributes for everyone' do
      policy = UserPolicy.new(player, player)
      expect(policy.permitted_attributes).to include(:email)
    end
  end

  describe 'Scope' do
    it 'shows all users to everyone' do
      scope = UserPolicy::Scope.new(player, User.all).resolve
      expect(scope).to eq(User.all)
    end
  end
end
