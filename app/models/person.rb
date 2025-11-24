# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  avatar_url     :string
#  birth_date     :date             not null
#  birth_place    :string
#  christian_name :string
#  data           :jsonb
#  deleted_at     :datetime
#  gender         :string           not null
#  name           :string           not null
#  nickname       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Person < ApplicationRecord
  include VnTextUtils
  include DataFieldable

  has_one :user
  has_one :teacher
  has_one :student
  has_many :phones, as: :phoneable
  has_many :emails, as: :emailable
  has_many :addresses, as: :addressable

  has_many :enrollments
  # has_many :classrooms, through: :enrollments

  has_many :teaching_assignments
  # has_many :classrooms, through: :teaching_assignments

  validates_presence_of :name, :gender, :birth_date
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  scope :in_classroom, -> (classroom) { joins(:enrollments).where('enrollments.classroom_id': classroom.id) }

  FIELD_SETS = [
    {
      key: 'person',
      fields: [
        { field_name: :christian_name, label: 'Tên Thánh' },
        { field_name: :name, label: 'Họ và Tên' },
        { field_name: :gender, label: 'Giới Tính', field_type: :select },
        { field_name: :nickname, label: 'Tên Ngắn', display_permission: -> (user) { user.admin? } },
        { field_name: :birth_date, label: 'Ngày Sinh', field_type: :date_field },
        { field_name: :birth_place, label: 'Nơi Sinh' },
        { field_name: :avatar_url, label: 'Ảnh Đại Diện' },
      ]
    }
  ]

  def full_name
    "#{christian_name} #{name}".squish
  end

  def sort_param
    normalize(reverse(name))
  end
end
