# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  area               :string
#  avatar_url         :string
#  birth_date         :date             not null
#  birth_place        :string
#  christian_name     :string
#  city               :string
#  data               :jsonb
#  date_baptism       :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  email              :string
#  gender             :string           not null
#  name               :string           not null
#  nickname           :string
#  phone              :string
#  place_baptism      :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  province           :string
#  province_code      :integer
#  street_address     :string
#  street_name        :string
#  street_number      :string
#  subregion          :string
#  ward               :string
#  ward_code          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
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
             :street_number, :street_name, :ward, :district, :city, :area,
             :date_baptism, :place_baptism, :date_communion, :place_communion,
             :date_confirmation, :place_confirmation, :date_declaration, :place_declaration

  has_many :enrollments
  has_many :teaching_assignments
end
