class Guidance < ApplicationRecord
  belongs_to :teacher
  belongs_to :classroom

  validates_presence_of :teacher_id, :classroom_id

  def sort_param
    "#{classroom.sort_param} #{position_sort_param}"
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
