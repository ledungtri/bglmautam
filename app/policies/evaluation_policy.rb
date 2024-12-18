class EvaluationPolicy < ApplicationPolicy
  def create?
    case record.evaluable_type
    when 'Enrollment'
      admin_or_teacher_of_enrollment?(record.evaluable)
    else
      super
    end
  end

  alias update? create?
  alias destroy? create?
end