class Teacher < ActiveRecord::Base
  has_many :instructions
  has_many :cells, through: :instructions

  validates_presence_of :full_name, :date_birth
  validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?
  validates :phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  # email = right format, allow nil

  def name
    if christian_name
      christian_name + ' ' + full_name
    else
      full_name
    end
  end

  def address
    street_number + ' ' + street_name + ', ' + ward + ', ' + district if street_name?
  end
end
