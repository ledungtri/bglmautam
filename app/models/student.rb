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
  include Person

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

  def name
    "#{christian_name} #{full_name}".squish
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

private

  def sync_person
    Person.create(student: self) unless person

    data_field = person.data || {}
    data_field[:student] = attributes.except(
      'id',
      'christian_name',
      'full_name',
      'gender',
      'date_birth',
      'place_birth',
      'phone',
      'street_number',
      'street_name',
      'ward',
      'district',
      'area',
      'created_at',
      'updated_at',
      'deleted_at',
      'person_id'
    )

    person.update(
      christian_name: christian_name,
      name: full_name,
      gender: gender,
      birth_date: date_birth,
      birth_place: place_birth,
      data: data_field
    )
  end
end
