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
class Evaluation < ApplicationRecord
  belongs_to :evaluable, polymorphic: true

  validates_presence_of :evaluable_type, :evaluable_id

  FIELD_SETS = [
    {
      key: 'evaluation',
      fields: [
        { field: :content, label: 'Nhận xét', field_type: :text_area, opts: { size: '110x10' } },
        { field: :evaluable_type, field_type: :hidden_field },
        { field: :evaluable_id, field_type: :hidden_field },
      ]
    }
  ]
end
