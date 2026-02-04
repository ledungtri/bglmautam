# == Schema Information
#
# Table name: data_schemas
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  entity     :string           not null
#  fields     :jsonb            not null
#  key        :string           not null
#  title      :string
#  weight     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DataSchema < ApplicationRecord
  SUPPORTED_ENTITIES = %w[Person Enrollment TeachingAssignment].freeze
  SUPPORTED_FIELD_TYPES = %w[text number select date checkbox textarea].freeze

  validates_presence_of :key, :entity, :fields, :weight

  def self.ransackable_attributes(auth_object = nil)
    %w[key entity title weight created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
