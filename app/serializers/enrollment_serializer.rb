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
#  index_enrollments_on_classroom_id           (classroom_id)
#  index_enrollments_on_deleted_at             (deleted_at)
#  index_enrollments_on_person_id              (person_id)
#  index_enrollments_on_student_id             (student_id)
#  index_enrollments_unique_student_classroom  (student_id,classroom_id) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class EnrollmentSerializer < ApplicationSerializer
  attributes :result
  belongs_to :person
  belongs_to :classroom
end
