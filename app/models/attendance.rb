class Attendance < ActiveRecord::Base
  belongs_to :student
  belongs_to :cell

  validates_presence_of :student_id, :cell_id, :result
end
