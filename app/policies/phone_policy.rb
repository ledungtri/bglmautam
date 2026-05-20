class PhonePolicy < ApplicationPolicy
  def create?
    admin_or_owner_of_person?(record.phoneable)
  end

  alias update? create?
  alias destroy? create?
end
