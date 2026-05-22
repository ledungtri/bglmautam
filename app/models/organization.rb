# == Schema Information
#
# Table name: organizations
#
#  id            :bigint           not null, primary key
#  city          :string
#  deleted_at    :datetime
#  district      :string
#  email         :string
#  name          :string           not null
#  phone         :string
#  slug          :string           not null
#  street_name   :string
#  street_number :string
#  ward          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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
