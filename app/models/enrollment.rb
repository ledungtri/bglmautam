# == Schema Information
#
# Table name: enrollments
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  result       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  person_id    :integer
#  student_id   :integer
#
# Indexes
#
#  index_enrollments_on_deleted_at  (deleted_at)
#  index_enrollments_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class Enrollment < ApplicationRecord
  include ClassroomRelationship

  belongs_to :student
  belongs_to :person
  has_one :evaluation, as: :evaluable
  has_many :grades
  has_many :attendances, as: :attendable

  before_validation :sync_person

  validates_presence_of :student_id, :person_id, :classroom_id, :result

  default_scope { includes(:student) }

  FIELD_SETS = [
    {
      key: 'enrollment',
      fields: [
        { label: 'Thiếu Nhi', field_type: :display, value_method: -> (e) { e.student.name } },
        { label: 'Lớp', field_type: :display, value_method: -> (e) { e.classroom.name } },
        { label: 'Kết Quả', field: :result, field_type: :select }
      ]
    }
  ]

  def sort_param
    student.sort_param
  end

private

  def sync_person
    self.person_id = Student.find(student_id).person_id
  end
end
