# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  avatar_url     :string
#  birth_date     :date
#  birth_place    :string
#  christian_name :string
#  data           :jsonb
#  deleted_at     :datetime
#  gender         :string           not null
#  name           :string           not null
#  nickname       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class PersonSerializer < ApplicationSerializer
  attributes :christian_name, :name, :gender, :birth_date, :birth_place,
             :data, :nickname, :avatar_url, :primary_phone

  has_many :enrollments
  has_many :teaching_assignments
  has_many :phones
  has_many :addresses
end
