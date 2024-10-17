# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  birth_date     :date             not null
#  birth_place    :string
#  christian_name :string
#  data           :jsonb
#  deleted_at     :datetime
#  gender         :string           not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Person < ApplicationRecord
  include VnTextUtils

  has_one :user
  has_many :phones, as: :phoneable
  has_many :emails, as: :emailable
  has_many :addresses, as: :addressable
  has_many :data_fields, as: :data_fieldable

  has_many :enrollments
  # has_many :classrooms, through: :enrollments

  has_many :guidances
  # has_many :classrooms, through: :guidances

  validates_presence_of :name, :gender, :birth_date
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  def full_name
    "#{christian_name} #{name}".squish
  end

  def sort_param
    normalize(reverse(name))
  end
end
