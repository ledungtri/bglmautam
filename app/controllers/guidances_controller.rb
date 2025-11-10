# == Schema Information
#
# Table name: guidances
#
#  id           :bigint           not null, primary key
#  deleted_at   :datetime
#  position     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  person_id    :integer
#  teacher_id   :integer
#
# Indexes
#
#  index_guidances_on_deleted_at  (deleted_at)
#  index_guidances_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class GuidancesController < SecondaryResourcesController
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
