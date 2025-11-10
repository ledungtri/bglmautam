# == Schema Information
#
# Table name: teachers
#
#  id             :bigint           not null, primary key
#  christian_name :string
#  date_birth     :date
#  deleted_at     :datetime
#  district       :string
#  email          :string
#  full_name      :string
#  gender         :string
#  named_date     :string
#  nickname       :string
#  occupation     :string
#  phone          :string
#  street_name    :string
#  street_number  :string
#  ward           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  person_id      :integer
#
# Indexes
#
#  index_teachers_on_deleted_at  (deleted_at)
#
class Teacher < ApplicationRecord
  include PersonConcern

  has_one :user
  has_many :guidances
  has_many :classrooms, through: :guidances
  belongs_to :person
  # TODO: email = right format, allow nil

  before_validation :sync_person

  FIELD_SETS = [
    {
      key: 'teacher',
      fields: [
        { field_name: :christian_name, label: 'Tên Thánh' },
        { field_name: :full_name, label: 'Họ và Tên' },
        { field_name: :gender, label: 'Giới Tính', field_type: :select },
        { field_name: :nickname, label: 'Tên Ngắn', display_permission: -> (user) { user.admin? } },
        { field_name: :date_birth, label: 'Ngày Sinh', field_type: :date_field },
        { field_name: :named_date, label: 'Bổn Mạng' },
        { field_name: :phone, label: 'Số Điện Thoại' },
        { field_name: :email, label: 'Email' },
        { field_name: :street_number, label: 'Số Nhà' },
        { field_name: :street_name, label: 'Đường' },
        { field_name: :ward, label: 'Phường/Xã' },
        { field_name: :district, label: 'Quận/Huyện' }
      ]
    }
  ]

  def sync_person
    person = person_id ? Person.find(person_id) : Person.new
    person.christian_name = christian_name
    person.name = full_name
    person.nickname = nickname
    person.gender = gender
    person.birth_date = date_birth
    person.data = [
      {
        key: 'additional_info',
        values: {
          named_date: named_date,
          occupation: occupation
        }
      }
    ]
    person.save

    person.phones.where(primary: true).first_or_create.update(number: phone) if phone
    person.emails.where(primary: true).first_or_create.update(address: email) if email
    person.addresses.where(primary: true).first_or_initialize.update(
      street_number: street_number,
      street_name: street_name,
      ward: ward,
      district: district
    ) if street_name

    self.person_id = person.id unless person_id
  end
end
