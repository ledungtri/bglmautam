# == Schema Information
#
# Table name: classrooms
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  family     :string
#  group      :string
#  level      :integer
#  location   :string
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_classrooms_on_deleted_at  (deleted_at)
#
class Classroom < ApplicationRecord
  has_many :enrollments
  has_many :students, through: :enrollments
  has_many :evaluations, through: :enrollments

  has_many :guidances
  has_many :teachers, through: :guidances

  validates_presence_of :year, :family
  validates :group, format: { with: /\A\d?[A-Z]?\z/, message: 'invalid input' }, allow_blank: true

  def long_year
    "#{year} - #{year + 1}" unless year.nil?
  end

  def name
    "#{family} #{level}#{group}".strip
  end

  def sort_param
    case
    when family == 'Trưởng Ban'
      '0'
    when family == 'Kỹ Thuật'
      '1'
    when family == 'Khai Tâm'
      "2#{level}#{group}"
    when family == 'Rước Lễ'
      "3#{level}#{group}"
    when family == 'Thêm Sức'
      "4#{level}#{group}"
    when family == 'Bao Đồng'
      "5#{level}#{group}"
    else
      '6'
    end
  end
end
