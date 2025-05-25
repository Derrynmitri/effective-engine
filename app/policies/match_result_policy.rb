class MatchResultPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    return true if user.admin?
    match = Match.find(record.match_id)
    match.white_player_id == user.id || match.black_player_id == user.id
  rescue ActiveRecord::RecordNotFound
    false
  end

  def edit?
    update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
