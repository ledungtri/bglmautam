# == Schema Information
#
# Table name: enrollments
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  result          :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  classroom_id    :integer
#  organization_id :bigint           not null
#  person_id       :integer
#  student_id      :integer
#
# Indexes
#
#  index_enrollments_on_classroom_id           (classroom_id)
#  index_enrollments_on_deleted_at             (deleted_at)
#  index_enrollments_on_organization_id        (organization_id)
#  index_enrollments_on_person_id              (person_id)
#  index_enrollments_on_student_id             (student_id)
#  index_enrollments_unique_student_classroom  (student_id,classroom_id) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (person_id => people.id)
#
class EnrollmentSerializer < ApplicationSerializer
  attributes :result, :average_grade, :attended_count, :mass_absence_count, :absence_count
  belongs_to :person
  belongs_to :classroom
  has_many :grades
  has_one :evaluation

  def average_grade
    object.average_grade
  end

  def attended_count
    attendance_counts[:attended]
  end

  def mass_absence_count
    attendance_counts[:mass_absence]
  end

  def absence_count
    attendance_counts[:absence]
  end

  private

  def attendance_counts
    @attendance_counts ||= begin
      attendances = object.attendances
      attended = attendances.count { |a| a.status == 'Hiện Diện' }
      mass_absence = attendances.count { |a| a.status == 'Vắng Lễ' }
      { attended: attended, mass_absence: mass_absence, absence: attendances.size - attended - mass_absence }
    end
  end
end
