class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
      admin?
  end

  def update?
    admin_or_self?(record)
  end

  alias destroy? create?
end