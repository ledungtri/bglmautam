class Instruction < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :teacher
  belongs_to :cell

  validates_presence_of :teacher_id, :cell_id

  def sort_param
    "#{cell.sort_param} #{position_sort_param}"
  end

  def position_sort_param
    case position
    when 'Tu Sĩ'
      1
    when 'GLV'
      2
    when 'Tiền GLV'
      3
    when 'Phụ Tá'
      4
    when 'Kiến Tập'
      5
    else
      6
    end
  end
end
