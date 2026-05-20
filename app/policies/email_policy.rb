class EmailPolicy < ApplicationPolicy
  def create?
    admin_or_owner_of_person?(record.emailable)
  end

  alias update? create?
  alias destroy? create?
end
