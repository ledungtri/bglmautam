# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  area               :string
#  avatar_url         :string
#  birth_date         :date             not null
#  birth_place        :string
#  christian_name     :string
#  city               :string
#  data               :jsonb
#  date_baptism       :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  email              :string
#  gender             :string           not null
#  name               :string           not null
#  nickname           :string
#  phone              :string
#  place_baptism      :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  province           :string
#  province_code      :integer
#  street_address     :string
#  street_name        :string
#  street_number      :string
#  subregion          :string
#  ward               :string
#  ward_code          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
#
# Indexes
#
#  index_people_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Person < ApplicationRecord
  acts_as_tenant :organization
  include VnTextUtils
  include DataFieldable

  def self.ransackable_attributes(auth_object = nil)
    %w[christian_name name gender birth_date birth_place nickname phone email
       street_number street_name ward district city area created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[enrollments teaching_assignments]
  end

  has_one :user
  has_one :teacher
  has_one :student
  has_many :enrollments
  # has_many :classrooms, through: :enrollments

  has_many :teaching_assignments
  # has_many :classrooms, through: :teaching_assignments

  validates_presence_of :name, :gender, :birth_date
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  validates_presence_of :date_baptism, if: :place_baptism?
  validates_presence_of :date_communion, if: :place_communion?
  validates_presence_of :date_confirmation, if: :place_confirmation?
  validates_presence_of :date_declaration, if: :place_declaration?

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
        { field_name: :phone, label: 'Số Điện Thoại' },
        { field_name: :email, label: 'Email' },
        { field_name: :street_number, label: 'Số Nhà' },
        { field_name: :street_name, label: 'Đường' },
        { field_name: :ward, label: 'Phường/Xã' },
        { field_name: :district, label: 'Quận/Huyện' },
        { field_name: :city, label: 'Thành Phố' },
        { field_name: :area, label: 'Xóm Giáo' },
        { field_name: :avatar_url, label: 'Ảnh Đại Diện' }
      ]
    },
    {
      key: 'sacraments',
      legend: 'Ngày Bí Tích',
      fields: [
        { field_name: :date_baptism, label: 'Rửa Tội', field_type: :date_field },
        { field_name: :place_baptism, label: 'Nơi Rửa Tội' },
        { field_name: :date_communion, label: 'Rước Lễ', field_type: :date_field },
        { field_name: :place_communion, label: 'Nơi Rước Lễ' },
        { field_name: :date_confirmation, label: 'Thêm Sức', field_type: :date_field },
        { field_name: :place_confirmation, label: 'Nơi Thêm Sức' },
        { field_name: :date_declaration, label: 'Tuyên Hứa', field_type: :date_field },
        { field_name: :place_declaration, label: 'Nơi Tuyên Hứa' },
      ]
    }
  ]

  def full_name
    "#{christian_name} #{name}".squish
  end

  def father_name
    "#{data_field_value('parents_info', 'father_christian_name')} #{data_field_value('parents_info', 'father_name')}".squish
  end

  def mother_name
    "#{data_field_value('parents_info', 'mother_christian_name')} #{data_field_value('parents_info', 'mother_name')}".squish
  end

  def full_address
    parts = [
      [street_number, street_name].compact.join(" ").presence,
      ward, district, city
    ].compact.reject(&:empty?)
    parts.join(", ").presence
  end

  def sort_param
    normalize(reverse(name))
  end
end
