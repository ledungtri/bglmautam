# == Schema Information
#
# Table name: teachers
#
#  id             :integer          not null, primary key
#  christian_name :string
#  date_birth     :date
#  deleted_at     :datetime
#  district       :string
#  email          :string
#  full_name      :string
#  named_date     :string
#  occupation     :string
#  phone          :string
#  street_name    :string
#  street_number  :string
#  ward           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_teachers_on_deleted_at  (deleted_at)
#
class Teacher < ApplicationRecord
  has_one :user
  has_many :guidances
  has_many :classrooms, through: :guidances

  validates_presence_of :full_name
  validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?
  validates :phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  # email = right format, allow nil

  def name
    "#{christian_name} #{full_name}".squish
  end

  def address
    "#{street_number} #{street_name}, #{ward}, #{district}" if street_name?
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
