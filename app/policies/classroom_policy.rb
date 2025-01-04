class ClassroomPolicy < ApplicationPolicy
  def update_evaluation?
    admin_or_teacher_of_classroom?(record)
  end
end