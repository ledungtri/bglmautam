class EvaluationPolicy < ApplicationPolicy
  def update?
    case record.evaluable
    when 'Enrollment'
      admin_or_teacher_of_enrollment?(record.evaluable)
    else
      super
    end
  end

  def destroy?
    case record.evaluable
    when 'Enrollment'
      admin_or_teacher_of_enrollment?(record.evaluable)
    else
      super
    end
  end
end