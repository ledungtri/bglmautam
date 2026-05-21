# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  avatar_url     :string
#  birth_date     :date             not null
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
  attributes :christian_name, :name, :full_name, :gender, :birth_date, :birth_place,
             :data, :nickname, :avatar_url,
             :phone, :email,
             :street_number, :street_name, :ward, :district, :city, :area

  has_many :enrollments
  has_many :teaching_assignments
end
