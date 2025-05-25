class MatchPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return true if user.admin?
    return false unless user.player? && user.player
    record.white_player_id == user.player.id || record.black_player_id == user.player.id
  end

  def new?
    true
  end

  def update?
    return true if user.admin?
    return false unless user.player? && user.player
    record.white_player_id == user.player.id || record.black_player_id == user.player.id
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
