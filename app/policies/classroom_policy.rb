class ClassroomPolicy < ApplicationPolicy
  def overview?
    admin?
  end

  def update_evaluation?
    admin_or_teacher_of_classroom?(record)
  end
end