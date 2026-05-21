# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
