class StudentPolicy < ApplicationPolicy
  def update?
    admin_or_teacher_of_student?(record)
  end
end