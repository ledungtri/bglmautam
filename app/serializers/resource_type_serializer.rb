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
#  organization_id :bigint
#
# Indexes
#
#  index_resource_types_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class ResourceTypeSerializer < ApplicationSerializer
  attributes :key, :value, :weight
end
