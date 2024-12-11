class AttendancePolicy < ApplicationPolicy
  def create?
    case record.attendable_type
    when 'Enrollment'
      admin_or_teacher_of_enrollment?(record.attendable)
    else
      super
    end
  end

  alias update? create?
  alias destroy? create?
end