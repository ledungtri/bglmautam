class UserPolicy < ApplicationPolicy
  def update?
    admin_or_self?(record)
  end
end