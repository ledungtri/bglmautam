class Instruction < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :teacher
  belongs_to :cell

  validates_presence_of :teacher_id, :cell_id
end
