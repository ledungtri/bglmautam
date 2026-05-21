# == Schema Information
#
# Table name: data_schemas
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  entity          :string           not null
#  fields          :jsonb            not null
#  key             :string           not null
#  title           :string
#  weight          :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#
# Indexes
#
#  index_data_schemas_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class DataSchemaSerializer < ApplicationSerializer
  attributes :key, :entity, :title, :weight, :fields
end
