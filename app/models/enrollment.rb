# == Schema Information
#
# Table name: enrollments
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  result       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  student_id   :integer
#
# Indexes
#
#  index_enrollments_on_deleted_at  (deleted_at)
#
class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :classroom

  validates_presence_of :student_id, :classroom_id, :result

  def sort_param
    student.sort_param
  end
end