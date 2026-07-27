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
#  organization_id :bigint           not null
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
class GradeSerializer < ApplicationSerializer
  attributes :name, :value, :weight, :enrollment_id
end
