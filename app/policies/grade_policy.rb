class GradePolicy < ApplicationPolicy
  def create?
    admin_or_teacher_of_enrollment?(record.enrollment)
  end

  alias update? create?
  alias destroy? create?
end