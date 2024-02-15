# == Schema Information
#
# Table name: guidances
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  position     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  teacher_id   :integer
#
# Indexes
#
#  index_guidances_on_deleted_at  (deleted_at)
#
class Guidance < ApplicationRecord
  belongs_to :teacher
  belongs_to :classroom

  validates_presence_of :teacher_id, :classroom_id

  default_scope { includes(:classroom) }
  default_scope { order('classrooms.year') }
  scope :for_year, -> (year) { where('classrooms.year' => year) }

  def sort_param
    "#{classroom.sort_param} #{position_sort_param}"
  end

  def position_sort_param
    positions = ["Tu Sĩ", "Huynh Trưởng", "Dự Trưởng", "Hiệp Sĩ", "GLV", "Tiền GLV", "Phụ Tá", "Kiến Tập"]
    positions.find_index(position) || positions.count
  end
end
