# == Schema Information
#
# Table name: resource_types
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  key             :string           not null
#  value           :string           not null
#  weight          :string           default("0"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_resource_types_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class ResourceType < ApplicationRecord
  acts_as_tenant :organization
  default_scope { order(:weight) }
  scope :for_key, -> (key) { where(key: key) }

  # Cached: `for_key(key).pluck(:value)` gets called once per record in several
  # per-record hot paths (e.g. `TeachingAssignment#position_sort_param`,
  # `Classroom#enrollments_overview`), and this table almost never changes.
  def self.values_for(key)
    Rails.cache.fetch(["resource_type_values", ActsAsTenant.current_tenant&.id, key], expires_in: 1.hour) do
      for_key(key).pluck(:value)
    end
  end
end
