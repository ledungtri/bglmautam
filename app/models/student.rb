# == Schema Information
#
# Table name: students
#
#  id                    :integer          not null, primary key
#  area                  :string
#  christian_name        :string
#  date_baptism          :date
#  date_birth            :date
#  date_communion        :date
#  date_confirmation     :date
#  date_declaration      :date
#  deleted_at            :datetime
#  district              :string
#  father_christian_name :string
#  father_full_name      :string
#  father_phone          :string
#  full_name             :string
#  gender                :string
#  mother_christian_name :string
#  mother_full_name      :string
#  mother_phone          :string
#  phone                 :string
#  place_baptism         :string
#  place_birth           :string
#  place_communion       :string
#  place_confirmation    :string
#  place_declaration     :string
#  street_name           :string
#  street_number         :string
#  ward                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_students_on_deleted_at  (deleted_at)
#
class Student < ApplicationRecord
  has_many :enrollments
  has_many :classrooms, through: :enrollments

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
    "#{christian_name} #{full_name}".squish
  end

  def address
    "#{street_number} #{street_name}, #{ward}, #{district}" if street_name?
  end

  def result(classroom)
    enrollments.where(student_id: id, classroom_id: classroom.id).take.result
  end

  def father_name
    "#{father_christian_name} #{father_full_name}".squish
  end

  def mother_name
    "#{mother_christian_name} #{mother_full_name}".squish
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
