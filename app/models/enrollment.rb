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

  validates_presence_of :student_id, :person_id, :classroom_id, :result

  default_scope { includes(:student) }

  before_save :sync_person

  FIELD_SETS = [
    {
      fields: [
        { label: 'Thiếu Nhi', field_type: :display, value_method: -> (e) { e.student.name } },
        { label: 'Lớp', field_type: :display, value_method: -> (e) { e.classroom.name } },
        { label: 'Kết Quả', field: :result, field_type: :select }
      ]
    }
  ]

  RESULT_OPTIONS = ['Đang Học', 'Dự Thính', 'Lên Lớp', 'Học Lại', 'Nghỉ Luôn', 'Chuyển Xứ']

  def sort_param
    student.sort_param
  end

private

  def sync_person
    self.person_id = student.person_id
  end
end
