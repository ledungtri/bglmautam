class Teacher < ApplicationRecord
  has_many :guidances
  has_many :classrooms, through: :guidances

  validates_presence_of :full_name, :date_birth
  validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?
  validates :phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  # email = right format, allow nil

  def name
    "#{christian_name} #{full_name}".squish
  end

  def address
    "#{street_number} #{street_name}, #{ward}, #{district}" if street_name?
  end
end
