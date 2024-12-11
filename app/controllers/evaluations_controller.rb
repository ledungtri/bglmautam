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

  def create
    skip_redirect
    super
  end

  def update
    skip_redirect
    super
  end

private

  def model_klass
    Evaluation
  end

  def permit_params
    [:content, :evaluable_type, :evaluable_id]
  end
end
