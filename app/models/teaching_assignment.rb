# == Schema Information
#
# Table name: teaching_assignments
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
#  index_teaching_assignments_on_classroom_id           (classroom_id)
#  index_teaching_assignments_on_deleted_at             (deleted_at)
#  index_teaching_assignments_on_person_id              (person_id)
#  index_teaching_assignments_on_teacher_id             (teacher_id)
#  index_teaching_assignments_unique_teacher_classroom  (teacher_id,classroom_id) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class TeachingAssignment < ApplicationRecord
  include ClassroomRelationship

  has_many :attendances, as: :attendable
  belongs_to :teacher
  belongs_to :person

  before_validation :sync_person

  validates_presence_of :teacher_id, :classroom_id

  def self.ransackable_attributes(auth_object = nil)
    %w[position teacher_id classroom_id person_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[classroom teacher attendances]
  end

  default_scope { includes(:teacher) }

  FIELD_SETS = [
    {
      key: 'teaching_assignment',
      fields: [
        { label: 'GLV', field_type: :display, value_method: -> (g) { g.teacher.name } },
        { label: 'Lớp', field_type: :display, value_method: -> (g) { g.classroom.name } },
        { label: 'Phụ Trách', field_name: :position, field_type: :select }
      ]
    }
  ]

  def sort_param
    "#{classroom.sort_param} #{position_sort_param} #{teacher.date_birth}"
  end

  def position_sort_param
    positions = ResourceType.for_key('teaching_assignment_position').pluck(:value)
    positions.find_index(position) || positions.count
  end

private

  def sync_person
    self.person_id = teacher.person_id
  end
end
