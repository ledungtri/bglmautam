class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    admin_or_self?(record)
  end

  alias update? create?
  alias destroy? create?
end