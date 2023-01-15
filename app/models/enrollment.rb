class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :classroom

  validates_presence_of :student_id, :classroom_id, :result

  def sort_param
    student.sort_param
  end
end
