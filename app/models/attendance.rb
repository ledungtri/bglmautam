class Attendance < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :student
  belongs_to :cell

  validates_presence_of :student_id, :cell_id, :result
end
