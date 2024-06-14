# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  birth_date     :date
#  birth_place    :string
#  christian_name :string
#  deleted_at     :datetime
#  gender         :string
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Person < ApplicationRecord
  include VnTextUtils

  has_many :phones, as: :phoneable
  has_many :emails, as: :emailable
  has_many :addresses, as: :addressable

  validates_presence_of :name, :gender, :date_birth
  validates :gender, inclusion: { in: %w[Nam Nữ], message: 'have to be either Nam or Nữ' }

  def full_name
    "#{christian_name} #{name}".squish
  end

  def sort_param
    normalize(reverse(name))
  end
end
