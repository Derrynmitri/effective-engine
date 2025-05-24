# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.referee?
  end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user == record
  end

  def destroy?
    user.admin? && user != record
  end

  def manage_roles?
    user.admin?
  end

  def permitted_attributes
    if user.admin?
      [ :email, :password, :password_confirmation, :role ]
    else
      [ :email, :password, :password_confirmation ]
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
