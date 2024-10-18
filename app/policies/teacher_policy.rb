class TeacherPolicy < ApplicationPolicy
  def update?
    admin_or_self_teacher?(record)
  end
end