class TeachingAssignmentPolicy < ApplicationPolicy
  def update?
    admin_or_teacher_of_teaching_assignment?(record)
  end
end
