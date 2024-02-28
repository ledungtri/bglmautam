class EvaluationsController < SecondaryResourcesController
  before_action :set_record, only: %i[admin_or_teacher_of?]
  before_action :admin_or_teacher_of?, only: %i[update destroy]

  def model_klass
    Evaluation
  end

  def permit_params
    [:content, :evaluable_type, :evaluable_id]
  end

private

  def admin_or_teacher_of?
    return if @current_user&.admin_or_teacher_of_enrollment?(@record.evaluable, @current_year)
    flash[:warning] = 'Action not allowed.'
    redirect_back(fallback_location: root_path)
  end
end
