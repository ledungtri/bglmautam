class EnrollmentPolicy < ApplicationPolicy
  def update?
    admin_or_teacher_of_enrollment?(record)
  end
end