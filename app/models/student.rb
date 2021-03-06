class Student < ActiveRecord::Base
  acts_as_paranoid

  has_many :attendances
  has_many :cells, through: :attendances

  validates_presence_of :full_name, :gender, :date_birth
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  validates_presence_of :date_baptism, if: :place_baptism?
  validates_presence_of :date_communion, if: :place_communion?
  validates_presence_of :date_confirmation, if: :place_confirmation?
  validates_presence_of :date_declaration, if: :place_declaration?

  validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?

  validates :phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  validates :father_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  validates :mother_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true

  def name
    "#{christian_name} #{full_name}".strip
  end

  def address
    "#{street_number} #{street_name}, #{ward}, #{district}" if street_name?
  end

  def result(cell)
    attendances.where(student_id: id, cell_id: cell.id).take.result
  end

  def father_name
    "#{father_christian_name} #{father_full_name}".strip
  end

  def mother_name
    "#{mother_christian_name} #{mother_full_name}".strip
  end

  def sort_param
    name.split(/\s+/).reverse!.join(' ')
        .gsub(/[áàảãạăắặằẳẵâấầẩẫậ]/, 'a')
        .gsub(/[íìỉĩị]/, 'i')
        .gsub(/[úùủũụưứừửữự]/, 'u')
        .gsub(/[éèẻẽẹêếềểễệ]/, 'e')
        .gsub(/[óòỏõọôốồổỗộơớờởỡợ]/, 'o')
        .gsub(/[đ]/, 'd')
        .gsub(/[ýỳỷỹỵ]/, 'y')
        .gsub(/[ÁÀẢÃẠĂẮẶẰẲẴÂẤẦẨẪẬ]/, 'A')
        .gsub(/[ÍÌỈĨỊ]/, 'I')
        .gsub(/[ÚÙỦŨỤƯỨỪỬỮỰ]/, 'U')
        .gsub(/[ÉÈẺẼẸÊẾỀỂỄỆ]/, 'E')
        .gsub(/[ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ]/, 'O')
        .gsub(/[Đ]/, 'D')
        .gsub(/[ÝỲỶỸỴ]/, 'Y')
  end
end
