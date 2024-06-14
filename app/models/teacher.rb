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
  include PersonConcern

  has_one :user
  has_many :guidances
  has_many :classrooms, through: :guidances
  # TODO: email = right format, allow nil

  FIELD_SETS = [
    {
      fields: [
        { field: :christian_name, label:'Tên Thánh' },
        { field: :full_name, label:'Họ và Tên' },
        { field: :date_birth, label:'Ngày Sinh', field_type: :date_field },
        {field: :named_date, label:'Bổn Mạng'},
        {field: :phone, label:'Số Điện Thoại'},
        {field: :email, label:'Email'},
        {field: :street_number, label:'Số Nhà'},
        {field: :street_name, label:'Đường'},
        {field: :ward, label:'Phường/Xã'},
        {field: :district, label:'Quận/Huyện'}
      ]
    }
  ]
end
