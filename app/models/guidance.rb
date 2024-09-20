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
class Guidance < ApplicationRecord
  include ClassroomRelationship

  has_many :attendances, as: :attendable
  belongs_to :teacher
  belongs_to :person

  before_validation :sync_person

  validates_presence_of :teacher_id, :classroom_id

  default_scope { includes(:teacher) }

  FIELD_SETS = [
    {
      fields: [
        { label: 'GLV', field_type: :display, value_method: -> (g) { g.teacher.name } },
        { label: 'Lớp', field_type: :display, value_method: -> (g) { g.classroom.name } },
        { label: 'Phụ Trách', field: :position, field_type: :select }
      ]
    }
  ]

  def sort_param
    "#{classroom.sort_param} #{position_sort_param}"
  end

  def position_sort_param
    positions = ResourceType.for_key('guidance_position').pluck(:value)
    positions.find_index(position) || positions.count
  end

private

  def sync_person
    self.person_id = teacher.person_id
  end
end
