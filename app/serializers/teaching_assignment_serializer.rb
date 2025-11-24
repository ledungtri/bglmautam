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
#  index_teaching_assignments_on_deleted_at  (deleted_at)
#  index_teaching_assignments_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class TeachingAssignmentSerializer < ApplicationSerializer
  attributes :position
  belongs_to :teacher
  belongs_to :classroom
end
