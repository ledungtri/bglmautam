# == Schema Information
#
# Table name: evaluations
#
#  id              :integer          not null, primary key
#  content         :string           not null
#  deleted_at      :datetime
#  evaluable_type  :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  evaluable_id    :integer
#  organization_id :bigint
#
# Indexes
#
#  index_evaluations_on_evaluable_type_and_evaluable_id  (evaluable_type,evaluable_id)
#  index_evaluations_on_organization_id                  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class EvaluationSerializer < ApplicationSerializer
  attributes :content, :evaluable_type, :evaluable_id
end
