# frozen_string_literal: true

class PersonSerializer < ApplicationSerializer
  attributes :christian_name, :name, :gender, :birth_date, :birth_place,
             :data, :nickname, :avatar_url

  has_many :enrollments
  has_many :teaching_assignments
  has_many :phones
  has_many :addresses
end
