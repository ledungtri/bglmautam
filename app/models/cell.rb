class Cell < ActiveRecord::Base
  has_many :attendances
  has_many :students, through: :attendances

  has_many :instructions
  has_many :teachers, through: :instructions

  validates_presence_of :year, :grade
  validates :group, format: { with: /\A\d?[A-Z]?\z/, message: 'invalid input' }, allow_blank: true

  def long_year
    year.to_s + ' - ' + (year + 1).to_s unless year.nil?
  end

  def name
    if group?
      grade + ' ' + group
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
      '2' + group
    when grade == 'Rước Lễ'
      '3' + group
    when grade == 'Thêm Sức'
      '4' + group
    when grade == 'Bao Đồng'
      '5' + group
    else
      '6'
    end
  end
end
