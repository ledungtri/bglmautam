class Cell < ActiveRecord::Base
  acts_as_paranoid

  has_many :enrollments
  has_many :students, through: :enrollments

  has_many :guidances
  has_many :teachers, through: :guidances

  validates_presence_of :year, :grade
  validates :group, format: { with: /\A\d?[A-Z]?\z/, message: 'invalid input' }, allow_blank: true

  def long_year
    "#{year} - #{year + 1}" unless year.nil?
  end

  def name
    if group?
      "#{grade} #{group}"
    else
      grade
    end
  end

  def sort_param
    case
    when grade == 'Trưởng Ban'
      '0'
    when grade == 'Kỹ Thuật'
      '1'
    when grade == 'Khai Tâm'
      "2#{group}"
    when grade == 'Rước Lễ'
      "3#{group}"
    when grade == 'Thêm Sức'
      "4#{group}"
    when grade == 'Bao Đồng'
      "5#{group}"
    else
      '6'
    end
  end
end
