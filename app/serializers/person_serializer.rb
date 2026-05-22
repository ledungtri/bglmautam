# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id              :integer          not null, primary key
#  area            :string
#  avatar_url      :string
#  birth_date      :date             not null
#  birth_place     :string
#  christian_name  :string
#  city            :string
#  data            :jsonb
#  deleted_at      :datetime
#  district        :string
#  email           :string
#  gender          :string           not null
#  name            :string           not null
#  nickname        :string
#  phone           :string
#  province        :string
#  street_address  :string
#  street_name     :string
#  street_number   :string
#  subregion       :string
#  ward            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#
# Indexes
#
#  index_people_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class PersonSerializer < ApplicationSerializer
  attributes :christian_name, :name, :full_name, :gender, :birth_date, :birth_place,
             :data, :nickname, :avatar_url,
             :phone, :email,
             :street_number, :street_name, :ward, :district, :city, :area

  has_many :enrollments
  has_many :teaching_assignments
end
