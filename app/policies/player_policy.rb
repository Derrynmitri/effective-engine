class PlayerPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def update?
    user&.admin? || record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
