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

  validates_presence_of :gender, :date_birth
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  validates_presence_of :date_baptism, if: :place_baptism?
  validates_presence_of :date_communion, if: :place_communion?
  validates_presence_of :date_confirmation, if: :place_confirmation?
  validates_presence_of :date_declaration, if: :place_declaration?

  validates :father_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
  validates :mother_phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true

  scope :in_classroom, -> (classroom) { joins(:enrollments).where('enrollments.classroom_id': classroom.id) }

  FIELD_SETS = [
    {
      legend: 'Thông Tin Cá Nhân',
      fields: [
        { field: :christian_name, label:'Tên Thánh' },
        { field: :full_name, label:'Họ và Tên' },
        { field: :date_birth, label:'Ngày Sinh', field_type: :date_field },
        {field: :place_birth, label:'Nơi Sinh' },
        {field: :gender, label:'Giới Tính', field_type: :select },
        {field: :phone, label:'Điện Thoại Cá Nhân' },
      ]
    },
    {
      legend: 'Ngày Bí Tích',
      fields: [
        { field: :date_baptism, label:'Rửa Tội', field_type: :date_field },
        {field: :place_baptism, label:'Nơi Rửa Tội' },
        { field: :date_communion, label:'Rước Lễ', field_type: :date_field },
        {field: :place_communion, label:'Nơi Rước Lễ' },
        { field: :date_confirmation, label:'Thêm Sức', field_type: :date_field },
        {field: :date_confirmation, label:'Nơi Thêm Sức' },
        { field: :date_declaration, label:'Tuyên Hứa', field_type: :date_field },
        {field: :date_declaration, label:'Nơi Tuyên Hứa' },
      ]
    },
    {
      legend: 'Địa Chỉ Nhà',
      fields: [
        { field: :street_number, label:'Số Nhà' },
        { field: :street_name, label:'Đường' },
        { field: :ward, label:'Phường/Xã' },
        { field: :district, label:'Quận/Huyện' },
        { field: :area, label:'Xóm Giáo' },
      ]
    },
    {
      legend: 'Thông Tin Cha Mẹ',
      fields: [
        { field: :father_christian_name, label:'Tên Thánh Cha' },
        { field: :father_full_name, label:'Họ và Tên Cha' },
        { field: :mother_christian_name, label:'Tên Thánh Mẹ' },
        { field: :mother_full_name, label:'Họ và Tên Mẹ' },
        { field: :father_phone, label:'Điện Thoại Cha' },
        { field: :mother_phone, label:'Điện Thoại Mẹ' },
      ]
    },
  ]

  GENDER_OPTIONS = ["Nam", "Nữ"]


  def result(classroom)
    enrollments.where(student_id: id, classroom_id: classroom.id).take.result
  end

  def father_name
    "#{father_christian_name} #{father_full_name}".squish
  end

  def mother_name
    "#{mother_christian_name} #{mother_full_name}".squish
  end

private

  # def sync_person
  #   Person.create(student: self) unless person
  #
  #   data_field = person.data || {}
  #   data_field[:student] = attributes.except(
  #     'id',
  #     'christian_name',
  #     'full_name',
  #     'gender',
  #     'date_birth',
  #     'place_birth',
  #     'phone',
  #     'street_number',
  #     'street_name',
  #     'ward',
  #     'district',
  #     'area',
  #     'created_at',
  #     'updated_at',
  #     'deleted_at',
  #     'person_id'
  #   )
  #
  #   person.update(
  #     christian_name: christian_name,
  #     name: full_name,
  #     gender: gender,
  #     birth_date: date_birth,
  #     birth_place: place_birth,
  #     data: data_field
  #   )
  # end
end
