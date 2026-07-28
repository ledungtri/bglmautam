# == Schema Information
#
# Table name: teaching_assignments
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  position        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  classroom_id    :integer
#  organization_id :bigint           not null
#  person_id       :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_teaching_assignments_on_classroom_id           (classroom_id)
#  index_teaching_assignments_on_deleted_at             (deleted_at)
#  index_teaching_assignments_on_organization_id        (organization_id)
#  index_teaching_assignments_on_person_id              (person_id)
#  index_teaching_assignments_on_teacher_id             (teacher_id)
#  index_teaching_assignments_unique_person_classroom   (person_id,classroom_id) UNIQUE WHERE (deleted_at IS NULL)
#  index_teaching_assignments_unique_teacher_classroom  (teacher_id,classroom_id) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (person_id => people.id)
#
class TeachingAssignmentSerializer < ApplicationSerializer
  attributes :position, :attendance_status_counts
  belongs_to :person
  belongs_to :classroom
  has_one :evaluation

  def attendance_status_counts
    object.attendances.group_by(&:status).transform_values(&:count)
  end
end
