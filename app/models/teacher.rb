# == Schema Information
#
# Table name: teachers
#
#  id              :integer          not null, primary key
#  christian_name  :string
#  date_birth      :date
#  deleted_at      :datetime
#  district        :string
#  email           :string
#  full_name       :string
#  gender          :string
#  nickname        :string
#  phone           :string
#  street_name     :string
#  street_number   :string
#  ward            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#  person_id       :integer
#
# Indexes
#
#  index_teachers_on_deleted_at       (deleted_at)
#  index_teachers_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Teacher < ApplicationRecord
  acts_as_tenant :organization
  include PersonConcern

  has_one :user
  has_many :teaching_assignments
  has_many :classrooms, through: :teaching_assignments
  belongs_to :person
  # TODO: email = right format, allow nil

  attr_accessor :named_date, :occupation

  after_find :load_additional_info
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
    person.phone = phone
    person.email = email
    person.street_number = street_number
    person.street_name = street_name
    person.ward = ward
    person.district = district
    person.save!
    person.update_data_field('additional_info', {
      'named_date' => named_date,
      'occupation' => occupation
    })

    self.person_id = person.id unless person_id
  end

  private

  def load_additional_info
    info = person&.data_field_by_key('additional_info') || {}
    self.named_date = info['named_date']
    self.occupation = info['occupation']
  end
end
