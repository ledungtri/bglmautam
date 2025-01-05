class PhonePolicy < ApplicationPolicy
  def create?
    true # TODO: Restrict policy
  end

  alias update? create?
  alias destroy? create?
end
