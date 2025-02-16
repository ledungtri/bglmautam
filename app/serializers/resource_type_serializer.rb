# == Schema Information
#
# Table name: resource_types
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  key        :string           not null
#  value      :string           not null
#  weight     :string           default("0"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ResourceTypeSerializer < ApplicationSerializer
  attributes :key, :value, :weight
end
