# == Schema Information
#
# Table name: students
#
#  id                 :integer          not null, primary key
#  area               :string
#  christian_name     :string
#  date_baptism       :date
#  date_birth         :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  full_name          :string
#  gender             :string
#  phone              :string
#  place_baptism      :string
#  place_birth        :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  street_name        :string
#  street_number      :string
#  ward               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
#  person_id          :integer
#
# Indexes
#
#  index_students_on_deleted_at       (deleted_at)
#  index_students_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Student < ApplicationRecord
  acts_as_tenant :organization
  include PersonConcern

  has_many :enrollments
  has_many :classrooms, through: :enrollments
  belongs_to :person

  attr_writer :father_christian_name, :father_full_name, :father_phone,
              :mother_christian_name, :mother_full_name, :mother_phone

  validates_presence_of :gender, :date_birth
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  validates_presence_of :date_baptism, if: :place_baptism?
  validates_presence_of :date_communion, if: :place_communion?
  validates_presence_of :date_confirmation, if: :place_confirmation?
  validates_presence_of :date_declaration, if: :place_declaration?

  scope :in_classroom, -> (classroom) { joins(:enrollments).where('enrollments.classroom_id': classroom.id) }

  before_validation :sync_person

  FIELD_SETS = [
    {
      key: 'personal_info',
      legend: 'Thông Tin Cá Nhân',
      fields: [
        { field_name: :christian_name, label:'Tên Thánh' },
        { field_name: :full_name, label:'Họ và Tên' },
        { field_name: :date_birth, label:'Ngày Sinh', field_type: :date_field },
        { field_name: :place_birth, label:'Nơi Sinh' },
        { field_name: :gender, label:'Giới Tính', field_type: :select },
        { field_name: :phone, label:'Điện Thoại Cá Nhân' },
      ]
    },
    {
      key: 'sacraments',
      legend: 'Ngày Bí Tích',
      fields: [
        { field_name: :date_baptism, label:'Rửa Tội', field_type: :date_field },
        { field_name: :place_baptism, label:'Nơi Rửa Tội' },
        { field_name: :date_communion, label:'Rước Lễ', field_type: :date_field },
        { field_name: :place_communion, label:'Nơi Rước Lễ' },
        { field_name: :date_confirmation, label:'Thêm Sức', field_type: :date_field },
        { field_name: :place_confirmation, label:'Nơi Thêm Sức' },
        { field_name: :date_declaration, label:'Tuyên Hứa', field_type: :date_field },
        { field_name: :place_declaration, label:'Nơi Tuyên Hứa' },
      ]
    },
    {
      key: 'parents_info',
      legend: 'Thông Tin Cha Mẹ',
      fields: [
        { field_name: :father_christian_name, label:'Tên Thánh Cha' },
        { field_name: :father_full_name, label:'Họ và Tên Cha' },
        { field_name: :mother_christian_name, label:'Tên Thánh Mẹ' },
        { field_name: :mother_full_name, label:'Họ và Tên Mẹ' },
        { field_name: :father_phone, label:'Điện Thoại Cha' },
        { field_name: :mother_phone, label:'Điện Thoại Mẹ' },
      ]
    },
    {
      key: 'address',
      legend: 'Địa Chỉ Nhà',
      fields: [
        { field_name: :street_number, label:'Số Nhà' },
        { field_name: :street_name, label:'Đường' },
        { field_name: :ward, label:'Phường/Xã' },
        { field_name: :district, label:'Quận/Huyện' },
        { field_name: :area, label:'Xóm Giáo' },
      ]
    }
  ]

  def result(classroom)
    enrollments.where(person_id: person_id, classroom_id: classroom.id).take.result
  end

  def father_name
    "#{father_christian_name} #{father_full_name}".squish
  end

  def mother_name
    "#{mother_christian_name} #{mother_full_name}".squish
  end

  # Lazy: only reads `person` (a query) the first time one of these is actually
  # accessed, instead of unconditionally on every Student load (was an `after_find`
  # callback — a severe N+1 across any endpoint that lists students/enrollments,
  # since `person` isn't preloaded by the time `after_find` fires on nested includes).
  def father_christian_name
    return @father_christian_name if defined?(@father_christian_name)
    @father_christian_name = parents_info['father_christian_name']
  end

  def father_full_name
    return @father_full_name if defined?(@father_full_name)
    @father_full_name = parents_info['father_name']
  end

  def father_phone
    return @father_phone if defined?(@father_phone)
    @father_phone = parents_info['father_phone']
  end

  def mother_christian_name
    return @mother_christian_name if defined?(@mother_christian_name)
    @mother_christian_name = parents_info['mother_christian_name']
  end

  def mother_full_name
    return @mother_full_name if defined?(@mother_full_name)
    @mother_full_name = parents_info['mother_name']
  end

  def mother_phone
    return @mother_phone if defined?(@mother_phone)
    @mother_phone = parents_info['mother_phone']
  end

  def sync_person
    person = person_id ? Person.find(person_id) : Person.new
    person.christian_name = christian_name
    person.name = full_name
    person.gender = gender
    person.birth_date = date_birth
    person.birth_place = place_birth
    person.phone = phone
    person.street_number = street_number
    person.street_name = street_name
    person.ward = ward
    person.district = district
    person.area = area
    person.date_baptism = date_baptism
    person.place_baptism = place_baptism
    person.date_communion = date_communion
    person.place_communion = place_communion
    person.date_confirmation = date_confirmation
    person.place_confirmation = place_confirmation
    person.date_declaration = date_declaration
    person.place_declaration = place_declaration
    person.save
    person.update_data_field('parents_info', {
      'father_christian_name' => father_christian_name,
      'father_name' => father_full_name,
      'father_phone' => father_phone,
      'mother_christian_name' => mother_christian_name,
      'mother_name' => mother_full_name,
      'mother_phone' => mother_phone
    })

    self.person_id = person.id unless person_id
  end

  private

  def parents_info
    @parents_info ||= person&.data_field_by_key('parents_info') || {}
  end
end
