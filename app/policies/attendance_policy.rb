class AttendancePolicy < ApplicationPolicy
  def update?
    case record.attendable_type
    when 'Enrollment'
      admin_or_teacher_of_enrollment?(record.attendable)
    else
      super
    end
  end
end