# == Schema Information
#
# Table name: grades
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  name            :string
#  value           :float
#  weight          :integer          default(1)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  enrollment_id   :integer
#  organization_id :bigint
#
# Indexes
#
#  index_grades_on_enrollment_id    (enrollment_id)
#  index_grades_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class GradesController < SecondaryResourcesController
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
    Grade
  end

  def permit_params
    [:name, :value, :enrollment_id]
  end
end
