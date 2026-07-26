# == Schema Information
#
# Table name: organizations
#
#  id             :bigint           not null, primary key
#  deleted_at     :datetime
#  email          :string
#  name           :string           not null
#  phone          :string
#  province       :string
#  province_code  :integer
#  slug           :string           not null
#  street_address :string
#  subregion      :string
#  ward_code      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_organizations_on_deleted_at  (deleted_at)
#  index_organizations_on_slug        (slug) UNIQUE
#
class Organization < ApplicationRecord
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
