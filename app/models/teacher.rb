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
#  gender         :string
#  named_date     :string
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
  # TODO: email = right format, allow nil

  before_validation :sync_person

  FIELD_SETS = [
    {
      key: 'teacher',
      fields: [
        { field: :christian_name, label:'Tên Thánh' },
        { field: :full_name, label:'Họ và Tên' },
        { field: :date_birth, label:'Ngày Sinh', field_type: :date_field },
        { field: :gender, label:'Giới Tính', field_type: :select },
        {field: :phone, label:'Số Điện Thoại'},
        {field: :email, label:'Email'},
        {field: :street_number, label:'Số Nhà'},
        {field: :street_name, label:'Đường'},
        {field: :ward, label:'Phường/Xã'},
        {field: :district, label:'Quận/Huyện'},
        {field: :named_date, label:'Bổn Mạng'}
      ]
    }
  ]

private

  def sync_person
    person = person_id ? Person.find(person_id) : Person.new
    person.christian_name = christian_name
    person.name = full_name
    person.gender = gender
    person.birth_date = date_birth
    person.data = [
      {
        key: 'additional',
        values: {
          named_date: named_date,
          occupation: occupation
        }
      }
    ]
    person.save!

    person.phones.where(primary: true).first_or_create(number: phone) unless phone.blank?
    person.emails.where(primary: true).first_or_create(address: email) unless email.blank?
    person.addresses.where(primary: true).first_or_create(
      street_number: street_number,
      street_name: street_name,
      ward: ward,
      district: district
    ) unless street_name.blank?

    self.person_id = person.id unless person_id
  end
end
