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
  include Person

  has_one :user
  has_many :guidances
  has_many :classrooms, through: :guidances
  # email = right format, allow nil
end
