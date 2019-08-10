class Instruction < ActiveRecord::Base
    belongs_to :teacher
    belongs_to :cell
    
    validates_presence_of :teacher_id, :cell_id
    # validate position
    # foreign key
end
