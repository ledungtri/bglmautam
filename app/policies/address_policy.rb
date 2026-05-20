class AddressPolicy < ApplicationPolicy
  def create?
    admin_or_owner_of_person?(record.addressable)
  end

  alias update? create?
  alias destroy? create?
end
