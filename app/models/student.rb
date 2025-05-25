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
#  person_id             :integer
#
# Indexes
#
#  index_students_on_deleted_at  (deleted_at)
#
class Student < ApplicationRecord
  include PersonConcern

  has_many :enrollments
  has_many :classrooms, through: :enrollments
  belongs_to :person

  validates_presence_of :gender, :date_birth
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  validates_presence_of :date_baptism, if: :place_baptism?
  validates_presence_of :date_communion, if: :place_communion?
  validates_presence_of :date_confirmation, if: :place_confirmation?
  validates_presence_of :date_declaration, if: :place_declaration?

  validates :father_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  validates :mother_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true

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
    enrollments.where(student_id: id, classroom_id: classroom.id).take.result
  end

  def father_name
    "#{father_christian_name} #{father_full_name}".squish
  end

  def mother_name
    "#{mother_christian_name} #{mother_full_name}".squish
  end

  def sync_person
    person = person_id ? Person.find(person_id) : Person.new
    person.christian_name = christian_name
    person.name = full_name
    person.gender = gender
    person.birth_date = date_birth
    person.birth_place = place_birth
    person.data = [
      {
        key: 'sacraments',
        values: {
          baptism_date: date_baptism,
          baptism_place: place_baptism,
          communion_date: date_communion,
          communion_place: place_communion,
          confirmation_date: date_confirmation,
          confirmation_place: place_confirmation,
          declaration_date: date_confirmation,
          declaration_place: place_confirmation
        }
      },
      {
        key: 'parents_info',
        values: {
          father_christian_name: father_christian_name,
          father_name: father_full_name,
          father_phone: father_phone,
          mother_christian_name: mother_christian_name,
          mother_name: mother_full_name,
          mother_phone: mother_phone
        }
      }
    ]
    person.save

    person.phones.where(primary: true).first_or_create.update(number: phone) if phone

    person.addresses.where(primary: true).first_or_initialize.update(
      street_number: street_number,
      street_name: street_name,
      ward: ward,
      district: district,
      area: area
    ) if street_name

    self.person_id = person.id unless person_id
  end
end
