# == Schema Information
#
# Table name: evaluations
#
#  id             :integer          not null, primary key
#  content        :string           not null
#  deleted_at     :datetime
#  evaluable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  evaluable_id   :integer
#
# Indexes
#
#  index_evaluations_on_evaluable_type_and_evaluable_id  (evaluable_type,evaluable_id)
#
class EvaluationsController < SecondaryResourcesController
  before_action :admin_or_teacher_of?, only: %i[update destroy]

private

  def model_klass
    Evaluation
  end

  def permit_params
    [:content, :evaluable_type, :evaluable_id]
  end

  def admin_or_teacher_of?
    return if @current_user&.admin_or_teacher_of_enrollment?(model_klass.find(params[:id]).evaluable, @current_year)
    flash[:warning] = 'Action not allowed.'
    redirect_back(fallback_location: root_path)
  end
end
