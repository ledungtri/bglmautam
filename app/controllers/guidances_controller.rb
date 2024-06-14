# == Schema Information
#
# Table name: guidances
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  position     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  teacher_id   :integer
#
# Indexes
#
#  index_guidances_on_deleted_at  (deleted_at)
#
class GuidancesController < SecondaryResourcesController
  before_action :auth, :admin?

  def update
    skip_redirect
    super
  end

private

  def model_klass
    Guidance
  end

  def permit_params
    [:position, :teacher_id, :classroom_id]
  end
end
